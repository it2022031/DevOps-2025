pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
        ANSIBLE_CONFIG = "infra/ansible/ansible-jenkins.cfg"
    }

    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Seed DB (K8s)') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/k8s/playbooks/k8s_seed_db.yml --limit k8s_nodes
        '''
            }
        }

        stage('Load Photos (K8s)') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/k8s/playbooks/k8s_load_photos.yml --limit k8s_nodes
        '''
            }
        }
    }

    post {
        success { echo ' seed-k8s: OK' }
        failure { echo ' seed-k8s: FAILED' }
    }
}
