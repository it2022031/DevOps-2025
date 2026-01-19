// Job DSL: creates pipeline jobs from SCM (your repo)

def repoUrl = 'https://github.com/it2022031/DevOps-2025.git'
def branch = '*/main'

// 1) infra-check (ping)
pipelineJob('infra-check') {
    definition {
        cpsScm {
            scm {
                git {
                    remote { url(repoUrl) }
                    branches(branch)
                }
            }
            scriptPath('vm/vagrant/jenkins/jenkinsfiles/test.groovy')
            lightweight(true)
        }
    }
}

// 2) deploy-vms
pipelineJob('deploy-vms') {
    definition {
        cpsScm {
            scm {
                git {
                    remote { url(repoUrl) }
                    branches(branch)
                }
            }
            scriptPath('vm/vagrant/jenkins/jenkinsfiles/deploy_vms.groovy')
            lightweight(true)
        }
    }
}
