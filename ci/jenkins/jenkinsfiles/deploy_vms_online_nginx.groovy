pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
        ANSIBLE_SSH_COMMON_ARGS  = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"
        ANSIBLE_TIMEOUT = "30"
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Preflight (paths + inventory)') {
            steps {
                sh '''
          set -e
          echo "WORKSPACE=$(pwd)"

          echo "== check paths =="
          test -f infra/inventories/cloud_vms.ini
          test -f ansible/online/vms/playbooks/site_vms_online_nginx.yml

          echo "== inventory file =="
          sed -n '1,200p' infra/inventories/cloud_vms.ini

          echo "== ansible version =="
          ansible --version

          echo "== inventory graph =="
          ansible-inventory -i infra/inventories/cloud_vms.ini --graph

          echo "== ping all =="
          ansible -i infra/inventories/cloud_vms.ini all -m ping
        '''
            }
        }

        stage('Deploy VMs Online (Nginx)') {
            steps {
                sh '''
          set -e
          ansible-playbook \
            -i infra/inventories/cloud_vms.ini \
            ansible/online/vms/playbooks/site_vms_online_nginx.yml \
            -v
        '''
            }
        }

        stage('Quick checks') {
            steps {
                sh '''
          set -e
          ansible -i infra/inventories/cloud_vms.ini front -b -m shell -a "systemctl is-active nginx && ss -lntp | egrep ':80|:8081' || true"
          ansible -i infra/inventories/cloud_vms.ini backend -b -m shell -a "systemctl is-active ds2025-backend && ss -lntp | egrep ':8080|:5432' || true"
        '''
            }
        }
    }

    post {
        success { echo ' deploy-vms-online-nginx: OK' }
        failure { echo ' deploy-vms-online-nginx: FAILED (δες Console Output)' }
    }
}
