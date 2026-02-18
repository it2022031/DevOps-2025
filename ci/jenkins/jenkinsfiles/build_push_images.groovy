pipeline {
    agent any
    options { timestamps() }

    environment {
        // Απενεργοποιούμε το SSH host key checking ώστε να μην μπλοκάρει το Ansible στο Jenkins
        ANSIBLE_HOST_KEY_CHECKING = "False"
        ANSIBLE_CONFIG = "infra/ansible/ansible-jenkins.cfg"
    }

    stages {
        // Κάνουμε checkout το repository (Jenkinsfile + Ansible playbooks/infra αρχεία)
        stage('Checkout') { steps { checkout scm } }

        stage('Build & Push images (on dockerhost)') {
            steps {
                // Διαβάζουμε το GHCR token από Jenkins Credentials και το περνάμε ως env var
                withCredentials([string(credentialsId: 'ghcr_token', variable: 'GHCR_TOKEN')]) {
                    sh '''
            set -e

            # Περνάμε το token ως extra-var ώστε να γίνει docker login στο GHCR και push των images
            ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/docker/playbooks/build_push_images.yml \
              --limit docker_nodes \
              -e "ghcr_token=$GHCR_TOKEN"
          '''
                }
            }
        }
    }

    post {
        success { echo "Images built & pushed to GHCR" }
        failure { echo "Build/push failed" }
    }
}
