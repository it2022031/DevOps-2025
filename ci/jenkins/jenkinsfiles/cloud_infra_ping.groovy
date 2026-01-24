pipeline {
    agent any
    options {
        timestamps()
        disableConcurrentBuilds()
    }

    parameters {
        string(name: 'LIMIT', defaultValue: 'all', description: 'Ansible limit (all / group / host pattern)')
        booleanParam(name: 'VERBOSE', defaultValue: false, description: 'Enable ansible -vvv')
    }

    environment {
        // ΒΑΛΕ το inventory σου εδώ (φτιάξε το κι αυτό στο repo αν δεν υπάρχει)
        INVENTORY = 'infra/ansible/cloud/cloud.ini'
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Preflight') {
            steps {
                sh '''
          set -euxo pipefail
          ansible --version
          test -f "${INVENTORY}" || (echo "Inventory not found: ${INVENTORY}" && exit 2)
        '''
            }
        }

        stage('Ping') {
            steps {
                sh '''
          set -euxo pipefail
          V=""
          if [ "${VERBOSE}" = "true" ]; then V="-vvv"; fi
          ansible -i "${INVENTORY}" "${LIMIT}" -m ping ${V}
        '''
            }
        }
    }
}
