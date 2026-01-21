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

        stage('Ping') {
            steps {
                sh '''
          set -e
          ansible -i infra/inventories/jenkins.ini 'all:!jenkins_nodes' -m ping
        '''
            }
        }
    }
}
