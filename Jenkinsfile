pipeline {
    agent any

    environment {
        KEYVAULT_NAME = "kv-databricks-fab"
        KV_SECRET_NAME = "customer-key-01"

        DATABRICKS_HOST = "https://adb-7405609173671370.10.azuredatabricks.net"
        SP_NAME = "spn-key-vault-jenk"
    }

    stages {

        stage('Azure Login') {
            steps {
                withCredentials([
                    string(credentialsId: 'AZURE_CLIENT_ID', variable: 'AZ_CLIENT_ID'),
                    string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'AZ_CLIENT_SECRET'),
                    string(credentialsId: 'AZURE_TENANT_ID', variable: 'AZ_TENANT_ID')
                ]) {
                    sh '''
                      az login --service-principal \
                        -u $AZ_CLIENT_ID \
                        -p $AZ_CLIENT_SECRET \
                        --tenant $AZ_TENANT_ID
                    '''
                }
            }
        }

        stage('Disable old Key Vault secret') {
            steps {
                sh '''
                  az keyvault secret set-attributes \
                    --vault-name ${KEYVAULT_NAME} \
                    --name ${KV_SECRET_NAME} \
                    --enabled false || true
                '''
            }
        }

        stage('Generate new Databricks OAuth secret') {
            steps {
                withCredentials([
                    string(credentialsId: 'DATABRICKS_TOKEN', variable: 'DB_TOKEN')
                ]) {
                    script {
                        env.NEW_SECRET = sh(
                            script: """
                            curl -s -X POST ${DATABRICKS_HOST}/api/2.0/accounts/servicePrincipals/generateOAuthSecret \
                              -H "Authorization: Bearer ${DB_TOKEN}" \
                              -H "Content-Type: application/json" \
                              -d '{ "service_principal_name": "${SP_NAME}" }' \
                              | jq -r '.client_secret'
                            """,
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }

        stage('Save new secret to Key Vault') {
            steps {
                sh '''
                  az keyvault secret set \
                    --vault-name ${KEYVAULT_NAME} \
                    --name ${KV_SECRET_NAME} \
                    --value "${NEW_SECRET}"
                '''
            }
        }
    }
}
