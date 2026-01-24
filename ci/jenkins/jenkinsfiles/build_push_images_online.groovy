pipeline {
    agent any
    options { timestamps() }

    environment {
        ANSIBLE_HOST_KEY_CHECKING = "False"
        ANSIBLE_SSH_COMMON_ARGS  = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"
        ANSIBLE_TIMEOUT = "30"
    }

    stages {
        stage('Checkout') { steps { checkout scm } }

        stage('Build & Push images (ONLINE dockerhost)') {
            steps {
                withCredentials([string(credentialsId: 'github-packages-token', variable: 'GHCR_TOKEN')]) {
                    sh '''
            set -e
            test -f infra/inventories/cloud_docker.ini
            test -f ansible/docker/playbooks/build_push_images.yml

            ansible -i infra/inventories/cloud_docker.ini docker_nodes -m ping
            ansible -i infra/inventories/cloud_docker.ini docker -m ping
            ansible-playbook \
              -i infra/inventories/cloud_docker.ini \
              ansible/docker/playbooks/build_push_images.yml \
              -l docker_nodes \
              -e "ghcr_token=$GHCR_TOKEN" \
              -v
          '''
                }
            }
        }
    }

    post {
        success { echo "✅ Images built & pushed to GHCR (ONLINE)" }
        failure { echo "❌ Build/push failed (ONLINE)" }
    }
}
