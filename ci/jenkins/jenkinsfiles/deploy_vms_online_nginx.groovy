pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
        // αν έχεις ansible cfg στο repo, άστο. αλλιώς μπορείς να το βγάλεις.
        // ANSIBLE_CONFIG = "infra/ansible/ansible-jenkins.cfg"

        // ΣΗΜΑΝΤΙΚΟ: στο cloud Jenkins συνήθως το ~ ΔΕΝ είναι το ίδιο.
        // Θα ορίσουμε key path explicit:
        ANSIBLE_PRIVATE_KEY_FILE = "/var/lib/jenkins/.ssh/id_vms"
        ANSIBLE_SSH_COMMON_ARGS  = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"
        ANSIBLE_TIMEOUT = "30"
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Preflight: show inventory') {
            steps {
                sh '''
          set -e
          echo "== Inventory file =="
          sed -n '1,200p' ansible/online/vms/inventories/cloud_vms.ini || true
          echo "== ansible-inventory graph =="
          ansible-inventory -i ansible/online/vms/inventories/cloud_vms.ini --graph
        '''
            }
        }

        stage('Deploy VMs Online (Nginx)') {
            steps {
                sh '''
          set -e
          ansible --version

          ansible-playbook \
            -i ansible/online/vms/inventories/cloud_vms.ini \
            ansible/online/vms/playbooks/site_vms_online_nginx.yml \
            -l vms \
            -v
        '''
            }
        }

        stage('Quick checks') {
            steps {
                sh '''
          set -e
          # Έλεγχος ότι front έχει nginx και ακούει
          ansible -i ansible/online/vms/inventories/cloud_vms.ini front -b -m shell -a "systemctl is-active nginx && ss -lntp | egrep ':80|:8081' || true"
          # Έλεγχος backend service
          ansible -i ansible/online/vms/inventories/cloud_vms.ini backend -b -m shell -a "systemctl is-active ds2025-backend && ss -lntp | egrep ':8080|:5432' || true"
        '''
            }
        }
    }

    post {
        success { echo '✅ deploy-vms-online-nginx: OK' }
        failure { echo '❌ deploy-vms-online-nginx: FAILED (δες Console Output)' }
    }
}
