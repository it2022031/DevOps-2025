pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Ansible Ping') {
            steps {
                sh '''
                cd vm/vagrant
                ansible -i hosts.ini all -m ping
                '''
            }
        }

        stage('Deploy All') {
            steps {
                sh '''
                cd vm/vagrant
                ansible-playbook -i hosts.ini playbooks/site.yml
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Deployment completed'
        }
        failure {
            echo '❌ Deployment failed'
        }
    }
}
