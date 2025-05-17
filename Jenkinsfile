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
                    // Create .env file for docker-compose
                    sh """
                        # Create necessary directories
                        mkdir -p app
                        
                        # Copy all application files to app directory
                        cp -r * app/ 2>/dev/null || true
                        
                        # Create environment file
                        echo "DOCKER_IMAGE=${DOCKER_IMAGE}" > .env
                        echo "DOCKER_TAG=${BUILD_NUMBER}" >> .env
                        echo "PROJECT_NAME=${PROJECT_NAME}" >> .env
                        
                        # Stop any existing containers
                        docker-compose -p ${PROJECT_NAME} down || true
                        
                        # Remove any old containers with the same name
                        docker ps -a | grep ${PROJECT_NAME} && docker rm -f \$(docker ps -a | grep ${PROJECT_NAME} | awk '{print \$1}') || true
                        
                        # Pull the latest image
                        docker pull ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        
                        # Start new containers
                        docker-compose -p ${PROJECT_NAME} up -d
                        
                        # Wait for container to start
                        sleep 10
                        
                        # Check if container is running
                        if ! docker ps | grep ${PROJECT_NAME}; then
                            echo "Container failed to start. Checking logs..."
                            docker-compose -p ${PROJECT_NAME} logs
                            exit 1
                        fi
                        
                        echo "Container is running. Checking logs..."
                        docker-compose -p ${PROJECT_NAME} logs
                    """
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
