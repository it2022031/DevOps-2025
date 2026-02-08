pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
        ANSIBLE_CONFIG = "infra/ansible/ansible-jenkins.cfg"

        ANSIBLE_PRIVATE_KEY_FILE = "/var/lib/jenkins/.ssh/jenkins_id"
        ANSIBLE_USER = "vagrant"
        ANSIBLE_SSH_COMMON_ARGS = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"
        ANSIBLE_TIMEOUT = "30"
    }

    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Preflight: wait SSH on dockerhost') {
            steps {
                sh '''
          set -e
          DOCKER_IP="192.168.56.104"
          echo "Waiting for SSH on ${DOCKER_IP}:22 ..."
          for i in $(seq 1 30); do
            if timeout 2 bash -lc "cat < /dev/null > /dev/tcp/${DOCKER_IP}/22" 2>/dev/null; then
              echo " SSH port is open on ${DOCKER_IP}"
              exit 0
            fi
            sleep 2
          done
          echo " dockerhost SSH (22) is not reachable. Make sure the VM is up (vagrant up dockerhost) and Jenkins key is authorized."
          exit 1
        '''
            }
        }

        stage('Ping dockerhost') {
            steps {
                sh '''
          set -e
          ansible -i infra/inventories/hosts_jenkins.ini docker_nodes -m ping
        '''
            }
        }

        stage('Deploy Docker stack') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/docker/playbooks/site_docker_jenkins.yml --limit docker_nodes
        '''
            }
        }

        stage('Docker ps') {
            steps {
                sh '''
          set -e
          # Εμφάνιση των containers που τρέχουν (πρώτες ~20 γραμμές) για γρήγορο έλεγχο
          ansible -i infra/inventories/hosts_jenkins.ini docker_nodes -b -m shell -a "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | sed -n '1,20p'" || true
        '''
            }
        }
    }

    post {
        success { echo ' Docker deployment completed successfully' }
        failure { echo ' Docker deployment failed – check logs' }
    }
}
