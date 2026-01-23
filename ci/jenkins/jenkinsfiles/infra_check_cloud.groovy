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

        stage('Ping (all VMs except Jenkins)') {
            steps {
                sh '''
          set -euo pipefail

          INV="infra/inventories/cloud.ini"
          if [ ! -f "$INV" ]; then
            echo "ERROR: inventory not found: $INV"
            echo "Available inventories:"
            ls -la infra/inventories || true
            exit 1
          fi

          # Exclude Jenkins host/group names (both patterns, just in case)
          ansible -i "$INV" 'all:!jenkins:!jenkins_nodes' -m ping
        '''
            }
        }
    }
}
