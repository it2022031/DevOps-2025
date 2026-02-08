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

          test -f infra/inventories/cloud_docker.ini
          test -f ansible/online/docker/playbooks/site_docker_online_nginx.yml

          # Τυπώνουμε το inventory για να είναι εμφανές στο Console Output σε τι hosts/groups θα τρέξει το Ansible
          echo "== inventory =="
          sed -n '1,160p' infra/inventories/cloud_docker.ini

          echo "== inventory graph =="
          ansible-inventory -i infra/inventories/cloud_docker.ini --graph

          echo "== ping docker nodes =="
          ansible -i infra/inventories/cloud_docker.ini docker_nodes -m ping
        '''
            }
        }

        stage('Deploy Docker Online (Nginx)') {
            steps {
                sh '''
          set -e
          # Τρέχουμε το playbook του online docker deployment με nginx (reverse proxy + πιθανό HTTPS/certbot)
          # -l docker_nodes: περιορίζει την εκτέλεση μόνο στα docker nodes του inventory
          # -v: verbose output για να φαίνεται καθαρά τι γίνεται σε κάθε task
          ansible-playbook \
            -i infra/inventories/cloud_docker.ini \
            ansible/online/docker/playbooks/site_docker_online_nginx.yml \
            -l docker_nodes \
            -v
        '''
            }
        }

        stage('Quick checks') {
            steps {
                sh '''
          set -e
          # ποια containers τρέχουν και σε ποια ports είναι δημοσιευμένα
          ansible -i infra/inventories/cloud_docker.ini docker_nodes -b -m shell -a \
            "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | sed -n '1,25p'" || true

          # Γρήγορος έλεγχος nginx + βασικών ports (80/443 και app ports)
          ansible -i infra/inventories/cloud_docker.ini docker_nodes -b -m shell -a \
            "systemctl is-active nginx && ss -lntp | egrep ':80|:443|:8080|:8081' || true" || true
        '''
            }
        }
    }

    post {
        success { echo ' deploy-docker-online-nginx: OK' }
        failure { echo ' deploy-docker-online-nginx: FAILED (δες Console Output)' }
    }
}
