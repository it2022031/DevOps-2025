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
          ansible-playbook -i hosts_jenkins.ini docker/playbooks/docker_seed_like_k8s.yml
        '''
            }
        }

        stage('Load Photos (Docker)') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini docker/playbooks/docker_load_photos_like_k8s.yml
        '''
            }
        }
    }

    post {
        success { echo '✅ seed-docker: OK' }
        failure { echo '❌ seed-docker: FAILED' }
    }
}
