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
pipelineJob('deploy-docker') {
    definition {
        cpsScm {
            scm {
                git {
                    remote { url(repoUrl) }
                    branches(branch)
                }
            }
            scriptPath('vm/vagrant/jenkins/jenkinsfiles/deploy_docker.groovy')
            lightweight(true)
        }
    }
}
pipelineJob('deploy-k8s') {
    definition {
        cpsScm {
            scm {
                git {
                    remote { url(repoUrl) }
                    branches(branch)
                }
            }
            scriptPath('vm/vagrant/jenkins/jenkinsfiles/deploy_k8s.groovy')
            lightweight(true)
        }
    }
}
pipelineJob('build-push-backend') {
    definition {
        cpsScm {
            scm { git { remote { url(repoUrl) }; branches(branch) } }
            scriptPath('vm/vagrant/jenkins/jenkinsfiles/build_push_backend.groovy')
            lightweight(true)
        }
    }
}

pipelineJob('build-push-frontend') {
    definition {
        cpsScm {
            scm { git { remote { url(repoUrl) }; branches(branch) } }
            scriptPath('vm/vagrant/jenkins/jenkinsfiles/build_push_frontend.groovy')
            lightweight(true)
        }
    }
}

