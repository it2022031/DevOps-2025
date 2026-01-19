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

        stage('Install Docker (infra)') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini playbooks/install_docker.yml
        '''
            }
        }

        stage('Deploy docker-compose stack') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini playbooks/docker_site.yml
        '''
            }
        }
    }

    post {
        success {
            echo '✅ Docker stack deployed successfully'
        }
        failure {
            echo '❌ Docker deploy failed – check console output'
        }
    }
}
