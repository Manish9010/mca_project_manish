pipeline {
    agent any

    stages {
        stage('Terraform Init') {
            steps {
                script {
                    sh 'terraform init -backend-config="access_key=${AWS_ACCESS_KEY_ID}" -backend-config="secret_key=${AWS_SECRET_ACCESS_KEY}"'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }

    post {
        always {
            script {
                // Send credentials via email and SMS
                // Use appropriate plugins or libraries to send emails and SMS
            }
        }
    }
}
