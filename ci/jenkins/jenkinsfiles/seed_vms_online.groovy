pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
        ANSIBLE_SSH_COMMON_ARGS  = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"
        ANSIBLE_TIMEOUT = "30"
    }

    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Seed DB on ONLINE VMs') {
            steps {
                sh '''
          set -e
          test -f infra/inventories/cloud_vms.ini
          test -f ansible/online/vms/playbooks/online_seed_db.yml

          ansible -i infra/inventories/cloud_vms.ini vms -m ping

          ansible-playbook \
            -i infra/inventories/cloud_vms.ini \
            ansible/online/vms/playbooks/online_seed_db.yml \
            -v
        '''
            }
        }
    }

    post {
        success { echo ' seed-vms-online: OK' }
        failure { echo ' seed-vms-online: FAILED' }
    }
}
