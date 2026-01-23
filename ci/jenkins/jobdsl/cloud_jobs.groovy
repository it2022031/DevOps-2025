pipeline {
    agent any
    options { timestamps() }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Create infra-check-cloud job') {
            steps {
                jobDsl(
                        targets: 'ci/jenkins/jobdsl/infra_check_cloud_only.groovy',
                        lookupStrategy: 'JENKINS_ROOT'
                )
            }
        }
    }
}
