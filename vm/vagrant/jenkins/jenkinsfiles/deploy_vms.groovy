pipeline {
    agent any

    options {
        timestamps()
        ansiColor('xterm')
    }

    environment {
        // Για lab/VMs: αποφεύγουμε interactive host key prompts
        ANSIBLE_HOST_KEY_CHECKING = "False"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Sanity: inventory + ansible version') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          echo "== ansible version =="
          ansible --version
          echo "== inventory =="
          cat hosts_jenkins.ini
        '''
            }
        }

        stage('Ping all targets') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible -i hosts_jenkins.ini all -m ping
        '''
            }
        }

        stage('Deploy VMs (site.yml)') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini playbooks/site.yml
        '''
            }
        }

        stage('Healthcheck') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini playbooks/healthcheck.yml
        '''
            }
        }
    }

    post {
        success {
            echo "✅ VM deploy pipeline finished successfully."
        }
        failure {
            echo "❌ VM deploy pipeline failed. Check Console Output above."
        }
    }
}
