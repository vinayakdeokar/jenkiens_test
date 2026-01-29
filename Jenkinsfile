pipeline {
    agent any

    parameters {
        choice(
            name: 'REGION',
            choices: ['primary_central_us', 'dr_east_us_2'],
            description: 'Azure region'
        )

        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'qa', 'uat', 'prod'],
            description: 'Environment'
        )

        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terraform action'
        )

        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Auto approve apply'
        )
    }

    stages {
        stage('Hello') {
            steps {
                echo 'Hello Jenkins! Pipeline working fine.'
                echo "REGION=${params.REGION}"
                echo "ENVIRONMENT=${params.ENVIRONMENT}"
                echo "ACTION=${params.ACTION}"
                echo "AUTO_APPROVE=${params.AUTO_APPROVE}"
            }
        }
    }
}
