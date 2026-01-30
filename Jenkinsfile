pipeline {
  agent any

  environment {
    KEYVAULT_NAME = "kv-databricks-fab"
    OLD_SECRET    = "db-fab-sec-01"
    NEW_SECRET    = "customer-key-01"

    DATABRICKS_HOST = "https://adb-7405609173671370.10.azuredatabricks.net"
    SP_ID = "<<<SERVICE_PRINCIPAL_ID>>>"
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

    stage('Disable old KV secret') {
      steps {
        sh '''
          az keyvault secret set-attributes \
            --vault-name ${KEYVAULT_NAME} \
            --name ${OLD_SECRET} \
            --enabled false || true
        '''
      }
    }

    stage('Generate Databricks SP secret') {
      steps {
        withCredentials([
          string(credentialsId: 'DATABRICKS_WS_TOKEN', variable: 'DB_TOKEN')
        ]) {
          script {
            env.NEW_VALUE = sh(
              script: """
                curl -s -X POST \
                  ${DATABRICKS_HOST}/api/2.0/service-principals/${SP_ID}/secrets \
                  -H "Authorization: Bearer ${DB_TOKEN}" \
                  -H "Content-Type: application/json" \
                | python3 -c "import sys, json; print(json.load(sys.stdin)['secret'])"
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
            --name ${NEW_SECRET} \
            --value "${NEW_VALUE}"
        '''
      }
    }
  }
}
