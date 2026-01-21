pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
        ANSIBLE_CONFIG = "infra/ansible/ansible-jenkins.cfg"

        // Force correct SSH identity for Jenkins → VMs
        ANSIBLE_PRIVATE_KEY_FILE = "/var/lib/jenkins/.ssh/jenkins_id"
        ANSIBLE_USER = "vagrant"
        ANSIBLE_SSH_COMMON_ARGS = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    }

    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Ping VMs') {
            steps {
                sh '''
          set -e
          ansible -i infra/inventories/hosts_jenkins.ini vms -m ping
        '''
            }
        }

        stage('Deploy VMs') {
            steps {
                sh '''
          set -e
          # Use Jenkins-safe playbook
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/vms/playbooks/site_jenkins.yml --limit vms
        '''
            }
        }

        stage('Healthcheck') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/vms/playbooks/healthcheck.yml --limit vms
        '''
            }
        }
    }

    post {
        success { echo '✅ Deploy VMs succeeded' }
        failure { echo '❌ Deploy VMs failed (see Console Output)' }
    }
}
