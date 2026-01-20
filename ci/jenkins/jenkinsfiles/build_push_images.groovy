pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build & Push images (on dockerhost)') {
            steps {
                withCredentials([string(credentialsId: 'ghcr_token', variable: 'GHCR_TOKEN')]) {
                    sh '''
            set -e
            cd vm/vagrant
            ansible-playbook -i hosts_jenkins.ini docker/playbooks/build_push_images.yml \
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
