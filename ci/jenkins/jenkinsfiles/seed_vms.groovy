pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
        ANSIBLE_CONFIG = "infra/ansible/ansible-jenkins.cfg"
    }

    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Seed DB (VMs)') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/vms/playbooks/vm_seed_like_k8s.yml --limit vms
        '''
            }
        }

        stage('Load Photos (VMs)') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/vms/playbooks/vm_load_photos_like_k8s.yml --limit vms
        '''
            }
        }
    }

    post {
        success { echo ' seed-vms: OK' }
        failure { echo ' seed-vms: FAILED' }
    }
}
