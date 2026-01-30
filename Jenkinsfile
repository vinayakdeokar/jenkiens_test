pipeline {
    agent any

    environment {
        KEYVAULT_NAME   = "my-keyvault"
        KV_SECRET_NAME  = "spn-client-secret"

        DATABRICKS_HOST = "https://adb-xxxxxxxx.xx.azuredatabricks.net"
        SECRET_SCOPE    = "spn-scope"
        SECRET_KEY      = "client-secret"
    }

    stages {

        stage('Azure Login using SPN') {
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

        stage('Read Secret from Key Vault') {
            steps {
                script {
                    env.SPN_SECRET = sh(
                        script: """
                        az keyvault secret show \
                          --vault-name ${KEYVAULT_NAME} \
                          --name ${KV_SECRET_NAME} \
                          --query value -o tsv
                        """,
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Create Databricks Secret Scope (idempotent)') {
            steps {
                withCredentials([
                    string(credentialsId: 'DATABRICKS_TOKEN', variable: 'DB_TOKEN')
                ]) {
                    sh '''
                        curl -s -X POST $DATABRICKS_HOST/api/2.0/secrets/scopes/create \
                        -H "Authorization: Bearer $DB_TOKEN" \
                        -H "Content-Type: application/json" \
                        -d '{
                              "scope": "'${SECRET_SCOPE}'"
                            }' || true
                    '''
                }
            }
        }

        stage('Put Secret into Databricks') {
            steps {
                withCredentials([
                    string(credentialsId: 'DATABRICKS_TOKEN', variable: 'DB_TOKEN')
                ]) {
                    sh '''
                        curl -X POST $DATABRICKS_HOST/api/2.0/secrets/put \
                        -H "Authorization: Bearer $DB_TOKEN" \
                        -H "Content-Type: application/json" \
                        -d '{
                              "scope": "'${SECRET_SCOPE}'",
                              "key": "'${SECRET_KEY}'",
                              "string_value": "'${SPN_SECRET}'"
                            }'
                    '''
                }
            }
        }
    }
}
