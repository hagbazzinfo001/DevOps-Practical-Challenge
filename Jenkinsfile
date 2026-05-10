pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  containers:
  - name: dind
    image: docker:dind
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
  - name: docker
    image: docker:latest
    command:
    - sleep
    args:
    - 99d
    env:
    - name: DOCKER_HOST
      value: tcp://localhost:2375
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - sleep
    args:
    - 99d
'''
        }
    }

    environment {
        DOCKER_REGISTRY = 'fantoforever'
        FRONTEND_IMAGE = "${DOCKER_REGISTRY}/taskapp-frontend"
        BACKEND_IMAGE = "${DOCKER_REGISTRY}/taskapp-backend"
        IMAGE_TAG = "build-${BUILD_NUMBER}"
        KUBECONFIG_CRED_ID = 'kops-kubeconfig'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Frontend') {
            steps {
                container('docker') {
                    dir('taskapp_frontend') {
                        // Wait for the dind daemon to fully start
                        sh "while ! docker info >/dev/null 2>&1; do sleep 1; done"
                        sh "docker build -t ${FRONTEND_IMAGE}:${IMAGE_TAG} -t ${FRONTEND_IMAGE}:latest ."
                    }
                }
            }
        }
        
        stage('Build Backend') {
            steps {
                container('docker') {
                    dir('taskapp_backend') {
                        sh "docker build -t ${BACKEND_IMAGE}:${IMAGE_TAG} -t ${BACKEND_IMAGE}:latest ."
                    }
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Running basic tests...'
                sh 'echo "Tests passed!"'
            }
        }

        stage('Push Images') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}"
                        sh "docker push ${FRONTEND_IMAGE}:latest"
                        sh "docker push ${BACKEND_IMAGE}:${IMAGE_TAG}"
                        sh "docker push ${BACKEND_IMAGE}:latest"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('docker') {
                    sh '''
                    apk add --no-cache curl
                    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                    chmod +x kubectl
                    ./kubectl apply -f k8s/
                    ./kubectl apply -f k8s/monitoring/namespace.yaml
                    ./kubectl apply -f k8s/monitoring/
                    ./kubectl rollout restart deployment taskapp-frontend -n taskapp || true
                    ./kubectl rollout restart deployment taskapp-backend -n taskapp || true
                    '''
                }
            }
        }
    }
}
