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

        stage('Ping k8shost') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible -i hosts_jenkins.ini k8s -m ping
        '''
            }
        }

        stage('Install MicroK8s') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini k8s/playbooks/microk8s_install.yml
        '''
            }
        }

        stage('Apply core manifests') {
            steps {
                sh '''
          set -e
          cd vm/vagrant
          ansible-playbook -i hosts_jenkins.ini k8s/playbooks/k8s_apply_core.yml
        '''
            }
        }
    }

    post {
        success { echo '✅ K8s deploy succeeded' }
        failure { echo '❌ K8s deploy failed (see Console Output)' }
    }
}
