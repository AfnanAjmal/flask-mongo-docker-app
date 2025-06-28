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
                        mkdir -p jenkins_app/templates
                        mkdir -p jenkins_app/static
                        
                        cp app.py requirements.txt Dockerfile jenkins_app/
                        cp -rv templates/* jenkins_app/templates/
                        cp -rv static/* jenkins_app/static/
                        
                        echo "Build environment prepared"
                        ls -R jenkins_app
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
                        
                        if docker ps -q --filter "name=${PROJECT_NAME}"; then
                            echo "Stopping existing Jenkins pipeline containers..."
                            docker stop \$(docker ps -q --filter "name=${PROJECT_NAME}") || true
                            docker rm \$(docker ps -aq --filter "name=${PROJECT_NAME}") || true
                        fi
                        
                        if docker ps | grep "flask_mongo_app"; then
                            echo "✅ Manual flask_mongo_app is running safely"
                        fi
                        
                        if docker images -q ${DOCKER_IMAGE}:latest; then
                            docker rmi ${DOCKER_IMAGE}:latest || true
                        fi
                        
                        sleep 2
                        
                        docker run -d \\
                            --name jenkins_flask_mongo_app \\
                            -p 5050:5000 \\
                            -e MONGO_URI='${MONGO_URI}' \\
                            -e SECRET_KEY='${SECRET_KEY}' \\
                            -e FLASK_APP=app.py \\
                            -e PYTHONPATH=/app \\
                            --memory=128m \\
                            --cpus=0.2 \\
                            --restart=unless-stopped \\
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
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
