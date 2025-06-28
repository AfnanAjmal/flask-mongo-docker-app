// Part 2: Jenkins Pipeline for Build Automation
pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'afnankhan03/flask-mongo-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
        PROJECT_NAME = 'flask-mongo-jenkins'  // Different project name for Part 2
        MONGO_URI = 'mongodb+srv://afnan:afnan@cluster0.jv1iq.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0'
        SECRET_KEY = 'ba9c73147efc5cf66b15a55e32410ef7cf1e4da81fa7a8391ada00da3c8b30c9'
    }
    
    options {
        disableConcurrentBuilds()
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Clean workspace and fetch code from GitHub
                cleanWs()
                checkout scm
            }
        }
        
        stage('Prepare Build Environment') {
            steps {
                script {
                    // Create directory structure for Part 2
                    sh '''
                        rm -rf jenkins_app || true
                        mkdir -p jenkins_app/templates
                        mkdir -p jenkins_app/static
                        
                        # Copy application files
                        cp app.py requirements.txt Dockerfile jenkins_app/
                        cp -rv templates/* jenkins_app/templates/
                        cp -rv static/* jenkins_app/static/
                        
                        echo "Build environment prepared with files:"
                        ls -R jenkins_app
                    '''
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image for containerized environment
                    sh """
                        cd jenkins_app
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        cd ..
                    """
                }
            }
        }
        
        stage('Deploy Container') {
            steps {
                script {
                    // Deploy using docker-compose with custom project name
                    sh """
                        # Stop existing container if any
                        docker-compose -p ${PROJECT_NAME} down || true
                        
                        # Start new container with volume mount
                        MONGO_URI='${MONGO_URI}' SECRET_KEY='${SECRET_KEY}' docker-compose -p ${PROJECT_NAME} up -d
                        
                        # Verify deployment
                        echo "Checking container status:"
                        docker ps | grep ${PROJECT_NAME}
                        
                        echo "Checking application logs:"
                        docker logs ${PROJECT_NAME}_jenkins_app
                    """
                }
            }
        }
    }
    
    post {
        always {
            // Cleanup
            sh 'docker system prune -f'
        }
        success {
            echo "Build phase completed successfully - Part 2 requirements met"
        }
        failure {
            echo "Build phase failed - Check container logs"
            sh 'docker logs ${PROJECT_NAME}_jenkins_app || true'
        }
    }
}
