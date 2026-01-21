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

        stage('Ping dockerhost') {
            steps {
                sh '''
          set -e
          ansible -i infra/inventories/jenkins.ini docker_nodes -m ping
        '''
            }
        }

        stage('Deploy Docker stack') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/jenkins.ini ansible/docker/playbooks/site_docker_jenkins.yml --limit docker_nodes
        '''
            }
        }
    }

    post {
        success { echo '✅ Docker deployment completed successfully' }
        failure { echo '❌ Docker deployment failed – check logs' }
    }
}
