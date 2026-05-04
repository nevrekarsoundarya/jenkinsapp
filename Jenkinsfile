pipeline {
    agent any

    // 1. Tell Jenkins which tool to use (based on the name in Global Tool Configuration)
    tools {
        terraform 'Terraform'
    }

    // 2. Inject secrets into the shell environment for Terraform to automatically find
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage('Checkout') {
            steps {
                // Pulls code from the GitHub repo linked to this job
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                // Initializes the working directory and downloads AWS providers
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                // Generates an execution plan to show what will be created
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                // Deploys the infrastructure. -auto-approve skips the manual 'yes' prompt.
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Deploy Application') {
            steps {
                // In a simple setup, this moves your app files to the web server directory
                // Note: Jenkins user needs permissions to write to /var/www/html
                sh 'echo "Deploying app to web server..."'
                sh 'sudo cp index.html /var/www/html/index.html || true'
            }
        }
    }

    post {
        always {
            // Clean up the workspace after the build to save disk space
            cleanWs()
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed. Check the console logs.'
        }
    }
}
