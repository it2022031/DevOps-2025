pipeline {
    agent any
    options { timestamps() }
    environment { ANSIBLE_HOST_KEY_CHECKING = "False" }

    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Seed DB (Docker)') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini docker/playbooks/docker_seed.yml
        '''
            }
        }

        stage('Load Photos (Docker)') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini docker/playbooks/docker_load_photos.yml
        '''
            }
        }
    }

    post {
        success { echo '✅ Docker seed + photos OK' }
        failure { echo '❌ Docker seed/photos failed' }
    }
}
