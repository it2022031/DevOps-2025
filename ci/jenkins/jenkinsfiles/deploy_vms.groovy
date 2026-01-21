pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
    }

    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Ping') {
            steps {
                sh '''
          set -e
          ansible -i infra/inventories/hosts_jenkins.ini all -m ping
        '''
            }
        }

        stage('Deploy VMs') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/vms/playbooks/site.yml --limit vms
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
