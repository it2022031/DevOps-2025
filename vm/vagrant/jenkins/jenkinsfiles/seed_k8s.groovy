pipeline {
    agent any
    options { timestamps() }
    environment { ANSIBLE_HOST_KEY_CHECKING = "False" }

    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Seed DB (K8s)') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini k8s/playbooks/k8s_seed_db.yml
        '''
            }
        }

        stage('Load Photos (K8s)') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini k8s/playbooks/k8s_load_photos.yml
        '''
            }
        }
    }

    post {
        success { echo '✅ K8s seed + photos OK' }
        failure { echo '❌ K8s seed/photos failed' }
    }
}
