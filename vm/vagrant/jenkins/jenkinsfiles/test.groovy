pipeline {
    agent any
    stages {
        stage('Checkout') { steps { checkout scm } }
        stage('Ping') {
            steps {
                sh '''
          cd vm/vagrant
          ansible -i hosts_jenkins.ini all -m ping
        '''
            }
        }
    }
}
