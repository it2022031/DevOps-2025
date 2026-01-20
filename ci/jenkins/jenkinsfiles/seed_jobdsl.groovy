pipeline {
    agent any
    options { timestamps() }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Run Job DSL') {
            steps {
                jobDsl(
                        targets: 'ci/jenkins/jobdsl/jobs.groovy',
                        removedJobAction: 'DELETE',
                        removedViewAction: 'DELETE',
                        ignoreExisting: false
                )
            }
        }
    }
}
