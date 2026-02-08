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
          # Εκτέλεση του playbook που κάνει deploy το DS2025 σε MicroK8s (cloud) και ρυθμίζει Nginx/HTTPS στο host
          ansible-playbook \
            -i infra/inventories/cloud_k8s.ini \
            ansible/online/k8s/playbooks/site_k8s_online_nginx.yml \
            -v
        '''
            }
        }

        stage('Quick status ') {
            steps {
                sh '''
          set -e
          # Προαιρετικός έλεγχος κατάστασης cluster (pods/services/ingress) για γρήγορη εικόνα μετά το deploy
          # Αν microk8s δεν είναι εγκατεστημένο σε κάποιο host, το || true αποτρέπει να αποτύχει όλο το pipeline
          ansible -i infra/inventories/cloud_k8s.ini all -b -m shell -a "microk8s kubectl -n ds2025 get pods,svc,ingress -o wide" || true
        '''
            }
        }
    }

    post {
        success { echo ' deploy-k8s-online-nginx: OK' }
        failure { echo ' deploy-k8s-online-nginx: FAILED (δες Console Output)' }
    }
}
