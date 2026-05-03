pipeline {
    agent any
    tools {
        terraform 'Terraform'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('TF Init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('TF Plan') {
            steps {
                sh 'terraform plan'
            }
        }
        stage('Deploy App') {
            steps {
                echo 'Deploying application to the web server...'
                // This is where you'd put commands to move your index.html
            }
        }
    }
}
