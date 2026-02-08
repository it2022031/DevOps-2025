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

        stage('Load photos on ONLINE VMs (idempotent)') {
            steps {
                sh '''
          set -e
          test -f infra/inventories/cloud_vms.ini
          test -f ansible/online/vms/playbooks/online_load_photos.yml

          ansible -i infra/inventories/cloud_vms.ini vms -m ping

          ansible-playbook \
            -i infra/inventories/cloud_vms.ini \
            ansible/online/vms/playbooks/online_load_photos.yml \
            -v
        '''
            }
        }
    }

    post {
        success { echo ' load-photos-vms-online: OK' }
        failure { echo ' load-photos-vms-online: FAILED' }
    }
}
