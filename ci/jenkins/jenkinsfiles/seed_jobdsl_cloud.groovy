pipeline {
    agent any
    options { timestamps() }

    environment {
        // Καλό να υπάρχει για να μην κολλάει με hosts/ssh αν σε άλλα jobs τρέχει ansible
        ANSIBLE_HOST_KEY_CHECKING = "False"
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Run Job DSL') {
            steps {
                jobDsl(
                        targets: 'ci/jenkins/jobdsl/jobs_cloud.groovy',
                        removedJobAction: 'DELETE',
                        removedViewAction: 'DELETE',
                        ignoreExisting: false
                )
            }
        }
    }
}
