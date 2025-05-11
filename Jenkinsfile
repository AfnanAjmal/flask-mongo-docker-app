pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'afnankhan03/flask-mongo-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
        PROJECT_NAME = 'flask-mongo-jenkins'
    }
    
    stages {
        stage('Test Pipeline') {
            steps {
                echo 'Testing Jenkins Pipeline - DevOps Assignment'
            }
        }
        
        stage('Checkout') {
            steps {
                cleanWs()  // Clean workspace before checkout
                checkout scm  // This uses GitHub credentials automatically
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    // Login to Docker Hub using Docker Hub credentials
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-id', 
                                                    usernameVariable: 'DOCKER_USER', 
                                                    passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                    }
                    // Push Docker image to Docker Hub
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-id') {
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    // Stop and remove existing containers for Jenkins (running on Port 5050)
                    sh "docker-compose -p ${PROJECT_NAME} down || true"
                    // Start new containers (this will run the app on Port 5050)
                    sh "docker-compose -p ${PROJECT_NAME} up -d"
                }
            }
        }
    }
    
    post {
        always {
            // Clean up workspace after build
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
