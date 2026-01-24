// Job DSL: creates ONLY the ping (infra-check) pipeline job from SCM

def repoUrl = 'https://github.com/it2022031/DevOps-2025.git'
def branch = '*/main'

// infra-check (ping)
pipelineJob('infra-check') {
    description('Ansible ping to verify connectivity to cloud VMs.')

    // Προαιρετικά: κρατάει λίγα builds για να μην φουσκώνει
    logRotator {
        numToKeep(30)
    }

    parameters {
        booleanParam('VERBOSE', false, 'Enable ansible -vvv')
        stringParam('LIMIT', 'all', 'Ansible limit (e.g. all, docker-vm, k8s-vms, vms, docker-vm:k8s-vms:vms)')
    }

    definition {
        cpsScm {
            scm {
                git {
                    remote { url(repoUrl) }
                    branches(branch)
                }
            }
            scriptPath('ci/jenkins/jenkinsfiles/cloud_ping.groovy')
            lightweight(true)
        }
    }
}
