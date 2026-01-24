pipelineJob('cloud/ping-cloud-vms') {
    description('Ping other cloud VMs using Ansible (docker-vm, k8s-vms, vms). Created by Job DSL.')

    logRotator {
        numToKeep(30)
        artifactNumToKeep(10)
    }

    parameters {
        stringParam('BRANCH', 'main', 'Git branch to use')
        booleanParam('VERBOSE', false, 'Enable -vvv in ansible')
    }

    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/it2022031/DevOps-2025.git')
                        // αν έχεις credentials στο Jenkins, βάλε:
                        // credentials('github-creds-id')
                    }
                    branch('$BRANCH')
                }
            }
            scriptPath('ci/jenkins/jenkinsfiles/cloud_ping.groovy')
            lightweight(true)
        }
    }
}
