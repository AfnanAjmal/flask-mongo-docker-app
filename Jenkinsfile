pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'afnankhan03/flask-mongo-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
        PROJECT_NAME = 'flask-mongo-jenkins'
        // Set MongoDB URI directly
        MONGO_URI = 'mongodb+srv://afnan:afnan@cluster0.jv1iq.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0'
        // Set the secret key directly
        SECRET_KEY = 'ba9c73147efc5cf66b15a55e32410ef7cf1e4da81fa7a8391ada00da3c8b30c9'
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
                    sh """
                        # Create necessary directories
                        mkdir -p app
                        
                        # Copy all application files to app directory
                        cp -r * app/ 2>/dev/null || true
                        
                        # Create environment file with variables
                        echo "DOCKER_IMAGE=${DOCKER_IMAGE}" > .env
                        echo "DOCKER_TAG=${BUILD_NUMBER}" >> .env
                        echo "PROJECT_NAME=${PROJECT_NAME}" >> .env
                        echo "MONGO_URI=${MONGO_URI}" >> .env
                        echo "SECRET_KEY=${SECRET_KEY}" >> .env
                        
                        # Stop any existing containers
                        docker-compose -p ${PROJECT_NAME} down || true
                        
                        # Remove any old containers with the same name
                        docker ps -a | grep ${PROJECT_NAME} && docker rm -f \$(docker ps -a | grep ${PROJECT_NAME} | awk '{print \$1}') || true
                        
                        # Clean up old images (keep the last 3)
                        docker images | grep ${DOCKER_IMAGE} | sort -r | awk 'NR>3 {print \$3}' | xargs -r docker rmi
                        
                        # Pull the latest image
                        docker pull ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        
                        # Start new containers with environment variables
                        MONGO_URI='${MONGO_URI}' SECRET_KEY='${SECRET_KEY}' docker-compose -p ${PROJECT_NAME} up -d
                        
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
