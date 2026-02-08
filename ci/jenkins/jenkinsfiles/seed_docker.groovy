pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
        ANSIBLE_CONFIG = "infra/ansible/ansible-jenkins.cfg"
    }

    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Seed DB (Docker)') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/docker/playbooks/docker_seed_like_k8s.yml --limit docker
        '''
            }
        }

        stage('Load Photos (Docker)') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/docker/playbooks/docker_load_photos_like_k8s.yml --limit docker
        '''
            }
        }
    }

    post {
        success { echo ' seed-docker: OK' }
        failure { echo ' seed-docker: FAILED' }
    }
}
