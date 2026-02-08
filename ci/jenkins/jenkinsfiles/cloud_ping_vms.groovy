pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Ping cloud nodes (vms, docker, k8s)') {
            steps {
                sh '''
          set -e
          ansible --version

          ansible -i infra/inventories/cloud.ini vms:docker:k8s -m ping
        '''
            }
        }
    }

    post {
        success { echo ' ping-cloud: OK' }
        failure { echo ' ping-cloud: FAILED (δες Console Output)' }
    }
}
