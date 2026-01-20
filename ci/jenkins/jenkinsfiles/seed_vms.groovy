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
          ansible-playbook -i hosts_jenkins.ini playbooks/vm_seed_like_k8s.yml
        '''
            }
        }

        stage('Load Photos (VMs)') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini playbooks/vm_load_photos_like_k8s.yml
        '''
            }
        }
    }

    post {
        success { echo '✅ seed-vms: OK' }
        failure { echo '❌ seed-vms: FAILED' }
    }
}
