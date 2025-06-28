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
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
            }
        }
        
        stage('Prepare Build Environment') {
            steps {
                script {
                    sh '''
                        rm -rf jenkins_app || true
                        mkdir -p jenkins_app
                        
                        echo "Copying all project files..."
                        cp -r . jenkins_app/
                        
                        echo "Build environment prepared with all files"
                        ls -la jenkins_app
                    '''
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
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
                    sh """
                        echo "Current running containers:"
                        docker ps --format "table {{.Names}}\t{{.Ports}}"
                        
                        echo "Stopping any existing Jenkins pipeline containers..."
                        docker compose -p ${PROJECT_NAME} down || true
                        
                        if docker ps | grep "flask_mongo_app"; then
                            echo "✅ Manual flask_mongo_app is running safely"
                        fi
                        
                        echo "Starting new deployment with docker compose..."
                        MONGO_URI='${MONGO_URI}' SECRET_KEY='${SECRET_KEY}' DOCKER_IMAGE='${DOCKER_IMAGE}' DOCKER_TAG='${DOCKER_TAG}' docker compose -p ${PROJECT_NAME} up -d
                        
                        sleep 5
                        
                        echo "Deployment status:"
                        docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"
                        
                        if docker ps | grep "jenkins_flask_mongo_app"; then
                            echo "✅ Jenkins pipeline container running on port 5050"
                            sleep 10
                            docker logs jenkins_flask_mongo_app
                        else
                            echo "❌ Deployment failed"
                        fi
                        
                        if docker ps | grep "flask_mongo_app"; then
                            echo "✅ Manual flask_mongo_app still running (port 5000)"
                        fi
                    """
                }
            }
        }
    }
    
    post {
        always {
            sh '''
                docker images | grep afnankhan03/flask-mongo-app || echo "No pipeline images found"
                docker ps | grep "flask_mongo_app" || echo "Manual container status: not running"
            '''
        }
        success {
            echo "Build completed successfully"
            echo "Jenkins pipeline app: http://your-aws-ip:5050"
            echo "Manual app: http://your-aws-ip:5000"
            sh 'docker ps | grep jenkins_flask_mongo_app'
        }
        failure {
            echo "Build failed"
            sh '''
                if docker ps | grep "jenkins_flask_mongo_app"; then
                    docker logs jenkins_flask_mongo_app
                else
                    echo "No pipeline containers running"
                fi
            '''
            sh 'free -h'
        }
    }
}
