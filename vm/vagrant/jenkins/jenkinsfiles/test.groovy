pipeline {
    agent any
    stages {
        stage('Checkout') { steps { checkout scm } }
        stage('Ping') {
            steps {
                sh '''
                  cd vm/vagrant
                  export ANSIBLE_HOST_KEY_CHECKING=False
                  ansible -i hosts_jenkins.ini all -m ping
                '''
            }
        }
    }
}
