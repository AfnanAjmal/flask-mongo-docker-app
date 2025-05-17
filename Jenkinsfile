pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'afnankhan03/flask-mongo-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
        PROJECT_NAME = 'flask-mongo-jenkins'
        MONGO_URI = 'mongodb+srv://afnan:afnan@cluster0.jv1iq.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0'
        SECRET_KEY = 'ba9c73147efc5cf66b15a55e32410ef7cf1e4da81fa7a8391ada00da3c8b30c9'
    }
    
    options {
        disableConcurrentBuilds()
    }
    
    stages {
        stage('Build and Deploy') {
            steps {
                script {
                    // Cleanup
                    sh '''
                        docker system prune -f
                        rm -rf jenkins_app || true
                    '''
                    
                    // Create directory for volume and copy files
                    sh '''
                        # Debug current directory
                        pwd
                        ls -la
                        
                        # Create directories
                        mkdir -p jenkins_app/templates
                        mkdir -p jenkins_app/static
                        
                        # Copy files with debug output
                        echo "Copying files..."
                        cp app.py requirements.txt Dockerfile jenkins_app/
                        
                        echo "Copying templates..."
                        cp -rv templates/* jenkins_app/templates/
                        
                        echo "Copying static files..."
                        cp -rv static/* jenkins_app/static/
                        
                        echo "Final structure:"
                        tree jenkins_app || ls -R jenkins_app
                    '''
                    
                    // Build and deploy
                    sh """
                        cd jenkins_app
                        
                        # Build new image
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        
                        # Stop existing container
                        docker-compose -p ${PROJECT_NAME} down || true
                        
                        # Start new container with volume
                        cd ..
                        MONGO_URI='${MONGO_URI}' SECRET_KEY='${SECRET_KEY}' docker-compose -p ${PROJECT_NAME} up -d
                        
                        # Show logs immediately
                        docker logs ${PROJECT_NAME}_jenkins_app
                        
                        # Verify container contents
                        echo "Verifying container contents:"
                        docker exec ${PROJECT_NAME}_jenkins_app ls -la /app
                        docker exec ${PROJECT_NAME}_jenkins_app ls -la /app/templates
                        
                        # Quick health check
                        sleep 3
                        if ! docker ps | grep ${PROJECT_NAME}; then
                            echo "Container failed to start"
                            docker logs ${PROJECT_NAME}_jenkins_app
                            exit 1
                        fi
                    """
                }
            }
        }
    }
    
    post {
        always {
            sh '''
                docker system prune -f
                rm -rf jenkins_app || true
            '''
        }
        failure {
            sh '''
                echo "Build failed. Container logs:"
                docker logs ${PROJECT_NAME}_jenkins_app || true
                echo "Container directory structure:"
                docker exec ${PROJECT_NAME}_jenkins_app ls -R /app || true
            '''
        }
    }
}
