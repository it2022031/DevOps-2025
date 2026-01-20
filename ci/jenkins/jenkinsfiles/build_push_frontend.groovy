//pipeline {
//    agent any
//
//    options { timestamps() }
//
//    environment {
//        REGISTRY = "ghcr.io"
//        IMAGE = "ghcr.io/it2022031/ds2025-frontend:latest"
//    }
//
//    stages {
//        stage('Bootstrap Docker on Jenkins VM (Ansible)') {
//            steps {
//                sh '''
//                  set -e
//                  cd vm/vagrant
//                  # εγκατάσταση docker στο jenkins VM μέσω ansible, με become
//                  ansible-playbook -i hosts_jenkins.ini jenkins/playbooks/jenkins_docker_prereqs.yml
//                '''
//            }
//        }
//        stage('Checkout') {
//            steps { checkout scm }
//        }
//
//        stage('Docker login (GHCR)') {
//            steps {
//                withCredentials([string(credentialsId: 'ghcr_token', variable: 'GHCR_TOKEN')]) {
//                    sh '''
//            set -e
//            echo "$GHCR_TOKEN" | docker login $REGISTRY -u it2022031 --password-stdin
//          '''
//                }
//            }
//        }
//
//        stage('Build frontend image') {
//            steps {
//                sh '''
//          set -e
//          cd vm/vagrant/docker
//          docker build -f dockerfiles/frontend.Dockerfile -t $IMAGE .
//        '''
//            }
//        }
//
//        stage('Push frontend image') {
//            steps {
//                sh '''
//          set -e
//          docker push $IMAGE
//        '''
//            }
//        }
//    }
//
//    post {
//        always {
//            sh 'docker logout ghcr.io || true'
//        }
//        success { echo '✅ Frontend image pushed to GHCR' }
//        failure { echo '❌ Frontend image build/push failed' }
//    }
//}
