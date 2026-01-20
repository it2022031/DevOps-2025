//pipeline {
//    agent any
//
//    options {
//        timestamps()
//    }
//
//    environment {
//        ANSIBLE_HOST_KEY_CHECKING = "False"
//    }
//
//    stages {
//        stage('Checkout') {
//            steps {
//                checkout scm
//            }
//        }
//
//        stage('Ping') {
//            steps {
//                sh '''
//          set -e
//          cd vm/vagrant
//          ansible -i hosts_jenkins.ini all -m ping
//        '''
//            }
//        }
//
//        stage('Deploy VMs (site_jenkins.yml)') {
//            steps {
//                sh '''
//          set -e
//          cd vm/vagrant
//          ansible-playbook -i hosts_jenkins.ini playbooks/site_jenkins.yml
//        '''
//            }
//        }
//    }
//
//    post {
//        success { echo '✅ Deploy VMs succeeded' }
//        failure { echo '❌ Deploy VMs failed (see Console Output)' }
//    }
//}
