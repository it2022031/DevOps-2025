pipeline {
    agent any
    options { timestamps() }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Generate Cloud Pipelines') {
            steps {
                jobDsl(
                        targets: 'ci/jenkins/jobdsl/cloud_pipelines.groovy',
                        removedJobAction: 'IGNORE',
                        removedViewAction: 'IGNORE',
                        ignoreExisting: false
                )
            }
        }
    }
}
