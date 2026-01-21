pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
        ANSIBLE_CONFIG = "infra/ansible/ansible-jenkins.cfg"

        // Force correct SSH identity (Jenkins → VMs)
        ANSIBLE_PRIVATE_KEY_FILE = "/var/lib/jenkins/.ssh/jenkins_id"
        ANSIBLE_USER = "vagrant"
        ANSIBLE_SSH_COMMON_ARGS = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"
        ANSIBLE_TIMEOUT = "30"
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Preflight: wait SSH on k8shost') {
            steps {
                sh '''
          set -e
          K8S_IP="192.168.56.105"
          echo "Waiting for SSH on ${K8S_IP}:22 ..."
          for i in $(seq 1 30); do
            if timeout 2 bash -lc "cat < /dev/null > /dev/tcp/${K8S_IP}/22" 2>/dev/null; then
              echo "✅ SSH port is open on ${K8S_IP}"
              exit 0
            fi
            sleep 2
          done
          echo "❌ k8shost SSH (22) is not reachable. Make sure the VM is up (vagrant up k8shost) and Jenkins key is authorized."
          exit 1
        '''
            }
        }

        stage('Ping k8s host') {
            steps {
                sh '''
          set -e
          ansible -i infra/inventories/hosts_jenkins.ini k8s_nodes -m ping
        '''
            }
        }

        stage('Install MicroK8s') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/k8s/playbooks/microk8s_install.yml --limit k8s_nodes
        '''
            }
        }

        stage('Apply core manifests') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/k8s/playbooks/k8s_apply_core.yml --limit k8s_nodes
        '''
            }
        }

        stage('Cluster status') {
            steps {
                sh '''
          set -e
          ansible -i infra/inventories/hosts_jenkins.ini k8s_nodes -b -m shell -a "microk8s kubectl -n ds2025 get pods,svc,ingress -o wide" || true
        '''
            }
        }
    }

    post {
        success { echo '✅ K8s deploy succeeded' }
        failure { echo '❌ K8s deploy failed (see Console Output)' }
    }
}
