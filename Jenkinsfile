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
                        mkdir -p jenkins_app
                        cp -r app.py requirements.txt templates static Dockerfile jenkins_app/
                        ls -la jenkins_app/
                    '''
                    
                    // Build and deploy
                    sh """
                        # Build new image
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} jenkins_app/
                        
                        # Stop existing container
                        docker-compose -p ${PROJECT_NAME} down || true
                        
                        # Start new container with volume
                        MONGO_URI='${MONGO_URI}' SECRET_KEY='${SECRET_KEY}' docker-compose -p ${PROJECT_NAME} up -d
                        
                        # Quick health check
                        sleep 3
                        if ! docker ps | grep ${PROJECT_NAME}; then
                            echo "Container failed to start"
                            docker logs ${PROJECT_NAME}_jenkins_app
                            exit 1
                        fi
                        
                        # Show container logs
                        docker logs ${PROJECT_NAME}_jenkins_app
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
    }
}
