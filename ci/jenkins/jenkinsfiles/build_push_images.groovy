pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
        ANSIBLE_CONFIG = "infra/ansible/ansible-jenkins.cfg"
    }

    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Build & Push images (on dockerhost)') {
            steps {
                withCredentials([string(credentialsId: 'ghcr_token', variable: 'GHCR_TOKEN')]) {
                    sh '''
            set -e
            ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/docker/playbooks/build_push_images.yml \
              --limit docker \
              -e "ghcr_token=$GHCR_TOKEN"
          '''
                }
            }
        }
    }

    post {
        success { echo "✅ Images built & pushed to GHCR" }
        failure { echo "❌ Build/push failed" }
    }
}
