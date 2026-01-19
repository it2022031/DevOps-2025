pipeline {
    agent any

    options {
        timestamps()
    }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Ping dockerhost') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible -i hosts_jenkins.ini docker -m ping
        '''
            }
        }

        stage('Deploy Docker stack') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini docker/playbooks/site_docker_jenkins.yml
        '''
            }
        }
    }

    post {
        success {
            echo '✅ Docker deployment completed successfully'
        }
        failure {
            echo '❌ Docker deployment failed – check logs'
        }
    }
}
