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
          test -f infra/inventories/cloud_k8s.ini
          test -f ansible/online/k8s/playbooks/site_k8s_online_nginx.yml

          echo "== inventory file =="
          sed -n '1,200p' infra/inventories/cloud_k8s.ini

          echo "== ansible version =="
          ansible --version

          echo "== inventory graph =="
          ansible-inventory -i infra/inventories/cloud_k8s.ini --graph

          echo "== ping all =="
          ansible -i infra/inventories/cloud_k8s.ini all -m ping
        '''
            }
        }

        stage('Deploy K8s Online (Nginx)') {
            steps {
                sh '''
          set -e
          ansible-playbook \
            -i infra/inventories/cloud_k8s.ini \
            ansible/online/k8s/playbooks/site_k8s_online_nginx.yml \
            -v
        '''
            }
        }

        stage('Quick status (optional)') {
            steps {
                sh '''
          set -e
          # Αν το inventory έχει host/group για k8s node, εδώ βγάζουμε μια γρήγορη εικόνα.
          # Αν το microk8s είναι installed, θα δεις pods/svc/ingress.
          ansible -i infra/inventories/cloud_k8s.ini all -b -m shell -a "microk8s kubectl -n ds2025 get pods,svc,ingress -o wide" || true
        '''
            }
        }
    }

    post {
        success { echo '✅ deploy-k8s-online-nginx: OK' }
        failure { echo '❌ deploy-k8s-online-nginx: FAILED (δες Console Output)' }
    }
}
