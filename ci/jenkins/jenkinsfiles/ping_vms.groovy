pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
        // Αν έχεις config ειδικά για Jenkins, άστο. Αλλιώς μπορείς να το βγάλεις.
        ANSIBLE_CONFIG = "infra/ansible/ansible-jenkins.cfg"

        // Αν στο cloud Jenkins χρειάζεσαι ssh key + user για να κάνει ansible ping στα VMs:
        ANSIBLE_PRIVATE_KEY_FILE = "/var/lib/jenkins/.ssh/jenkins_id"
        ANSIBLE_USER = "vagrant"
        ANSIBLE_SSH_COMMON_ARGS = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"
        ANSIBLE_TIMEOUT = "30"
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Ping 3 VMs (backend, db, front)') {
            steps {
                sh '''
          set -e
          # Διάλεξε ΕΝΑ από τα παρακάτω, ανάλογα πώς είναι το inventory σου:

          # (1) Αν έχεις group [vms] που περιέχει backend, db, front:
          ansible -i infra/inventories/hosts_jenkins.ini vms -m ping

          # (2) Αν ΔΕΝ έχεις group vms, αλλά έχεις hosts backend, db, front:
          # ansible -i infra/inventories/hosts_jenkins.ini backend:db:front -m ping
        '''
            }
        }
    }

    post {
        success { echo '✅ ping-vms: OK' }
        failure { echo '❌ ping-vms: FAILED (δες Console Output)' }
    }
}
