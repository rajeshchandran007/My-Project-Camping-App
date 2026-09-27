pipeline {
    agent any
    
    tools {
        nodejs 'node24'
    }
    
    environment {
        // Define your Docker Hub Registry info
        DOCKER_HUB_USER  = 'rajeshchandran007'
        IMAGE_NAME       = 'camping-app-nodejs'
        IMAGE_TAG        = "${BUILD_NUMBER}"
        FULL_IMAGE_PATH  = "${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
        SCANNER_HOME     = tool 'sonar-scanner'
    }
    
    stages {
        stage('git checkout') {
            steps {
                git branch: 'main', 
                    credentialsId: 'github-credential', 
                    url: 'https://github.com/rajeshchandranaws5/Camping-App-Nodejs.git'
            }
        }
        
        stage('npm install') {
            steps {
                echo 'Installing application dependencies using Node 24...'
                sh 'npm install'
            }
        }
        
        stage('sonar scanning') {
            steps {
                script {
                    // Dynamically provisions the 'sonar-scanner' tool setup by its class path
                    def scannerHome = tool name: 'sonar-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                    withSonarQubeEnv('sonar-server') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectName=${IMAGE_NAME} \
                            -Dsonar.projectKey=${IMAGE_NAME} \
                            -Dsonar.sources=. \
                            -Dsonar.exclusions=node_modules/**,**/k8s-manifests/**
                        """
                    }
                }
            }
        }
        
        stage('Trivy FS') {
            steps {
                echo 'Scanning source filesystem for dependency vulnerabilities...'
                sh 'trivy fs --format table -o fs-report.html --severity HIGH,CRITICAL --exit-code 0 .'
            }
        }
        
        stage('Docker Build') {
            steps {
                sh "docker build -t ${FULL_IMAGE_PATH} ."
            }
        }
        
        stage('Trivy Image') {
            steps {
                echo "Scanning Docker image ${FULL_IMAGE_PATH} for system vulnerabilities..."
                sh "trivy image --format table -o image-report.html --severity CRITICAL --exit-code 0 ${FULL_IMAGE_PATH}"
            }
        }
        
       stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-credential', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    // FIXED: Changed double quotes to single quotes to prevent Groovy variable splitting
                    sh 'echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin'
                }
            }
        } 
        
        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-credential', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    // FIXED: Using single quotes ensures Jenkins maps the shell environment properties accurately
                    sh 'docker push ${FULL_IMAGE_PATH}'
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up the build workspace...'
            cleanWs()
        }
    }
}
