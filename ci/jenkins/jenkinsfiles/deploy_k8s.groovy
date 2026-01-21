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
          ansible -i infra/inventories/hosts_jenkins.ini k8s -m ping
        '''
            }
        }

        stage('Install MicroK8s') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/k8s/playbooks/microk8s_install.yml --limit k8s
        '''
            }
        }

        stage('Apply core manifests') {
            steps {
                sh '''
          set -e
          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/k8s/playbooks/k8s_apply_core.yml --limit k8s
        '''
            }
        }

//        stage('Seed DB + Load photos') {
//            steps {
//                sh '''
//          set -e
//          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/k8s/playbooks/k8s_seed_db.yml --limit k8s
//          ansible-playbook -i infra/inventories/hosts_jenkins.ini ansible/k8s/playbooks/k8s_load_photos.yml --limit k8s
//        '''
//            }
//        }
    }

    post {
        success { echo '✅ K8s deploy succeeded' }
        failure { echo '❌ K8s deploy failed (see Console Output)' }
    }
}
