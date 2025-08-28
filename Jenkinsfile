pipeline {
  agent any
  environment {
    // Change to your Docker Hub repo: docker.io/<username>/devops-sample
    IMAGE_REPO = "docker.io/thiru817/devops-sample"
    IMAGE_TAG  = "${BUILD_NUMBER}"
    KUBE_NAMESPACE = "demo"
    DOCKER_CREDENTIALS = "dockerhub-creds"
    KUBECONFIG_CREDENTIALS = "kubeconfig"
  }
  options {
    timestamps()
    ansiColor('xterm')
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Build & Test') {
      steps {
        sh '''
          set -euxo pipefail
          docker build --target test -t $IMAGE_REPO:test .
        '''
      }
    }
    stage('Build Image') {
      steps {
        sh '''
          set -euxo pipefail
          docker build -t $IMAGE_REPO:$IMAGE_TAG .
        '''
      }
    }
    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS, usernameVariable: 'thiru817', passwordVariable: 'Thirumurugan12@')]) {
          sh '''
            set -euxo pipefail
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push $docker.io/thiru817/devops-sample:$IMAGE_TAG
          '''
        }
      }
    }
    stage('Deploy to K8s') {
      steps {
        withCredentials([file(credentialsId: env.KUBECONFIG_CREDENTIALS, variable: 'KUBECONFIG_FILE')]) {
          sh '''
            set -euxo pipefail
            export KUBECONFIG="$KUBECONFIG_FILE"

            # Ensure namespace exists
            kubectl get ns $KUBE_NAMESPACE >/dev/null 2>&1 || kubectl create namespace $KUBE_NAMESPACE

            # Apply Deployment with the new image
            sed "s|IMAGE_PLACEHOLDER|$IMAGE_REPO:$IMAGE_TAG|g" k8s/deployment.yaml | kubectl -n $KUBE_NAMESPACE apply -f -

            # Apply Service
            kubectl -n $KUBE_NAMESPACE apply -f k8s/service.yaml

            # Wait for rollout
            kubectl -n $KUBE_NAMESPACE rollout status deploy/devops-sample
          '''
        }
      }
    }
  }
  post {
    always {
      sh 'docker logout || true'
    }
  }
}
