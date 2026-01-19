pipeline {
    agent any
    options { timestamps() }
    environment { ANSIBLE_HOST_KEY_CHECKING = "False" }

    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Seed DB (VMs)') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini playbooks/seed_db.yml
        '''
            }
        }

        stage('Load Photos (VMs)') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini playbooks/load_photos_dbvm.yml
        '''
            }
        }
    }

    post {
        success { echo '✅ VMs seed + photos OK' }
        failure { echo '❌ VMs seed/photos failed' }
    }
}
