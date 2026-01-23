// Job DSL: Cloud Jenkins - creates pipeline jobs from SCM (your repo)

def repoUrl = 'https://github.com/it2022031/DevOps-2025.git'
def branch  = '*/main'

// 0) infra-check-cloud (ansible ping all VMs except Jenkins)
pipelineJob('infra-check-cloud') {
    definition {
        cpsScm {
            scm {
                git {
                    remote { url(repoUrl) }
                    branches(branch)
                }
            }
            scriptPath('ci/jenkins/jenkinsfiles/infra_check_cloud.groovy')
            lightweight(true)
        }
    }
}

// 1) deploy-vms
pipelineJob('deploy-vms') {
    definition {
        cpsScm {
            scm { git { remote { url(repoUrl) }; branches(branch) } }
            scriptPath('ci/jenkins/jenkinsfiles/deploy_vms.groovy')
            lightweight(true)
        }
    }
}

// 2) deploy-docker
pipelineJob('deploy-docker') {
    definition {
        cpsScm {
            scm { git { remote { url(repoUrl) }; branches(branch) } }
            scriptPath('ci/jenkins/jenkinsfiles/deploy_docker.groovy')
            lightweight(true)
        }
    }
}

// 3) deploy-k8s
pipelineJob('deploy-k8s') {
    definition {
        cpsScm {
            scm { git { remote { url(repoUrl) }; branches(branch) } }
            scriptPath('ci/jenkins/jenkinsfiles/deploy_k8s.groovy')
            lightweight(true)
        }
    }
}

// 4) build-push-images
pipelineJob('build-push-images') {
    definition {
        cpsScm {
            scm { git { remote { url(repoUrl) }; branches(branch) } }
            scriptPath('ci/jenkins/jenkinsfiles/build_push_images.groovy')
            lightweight(true)
        }
    }
}

// 5) seed-* (if you keep these)
pipelineJob('seed-vms') {
    definition {
        cpsScm {
            scm { git { remote { url(repoUrl) }; branches(branch) } }
            scriptPath('ci/jenkins/jenkinsfiles/seed_vms.groovy')
            lightweight(true)
        }
    }
}

pipelineJob('seed-docker') {
    definition {
        cpsScm {
            scm { git { remote { url(repoUrl) }; branches(branch) } }
            scriptPath('ci/jenkins/jenkinsfiles/seed_docker.groovy')
            lightweight(true)
        }
    }
}

pipelineJob('seed-k8s') {
    definition {
        cpsScm {
            scm { git { remote { url(repoUrl) }; branches(branch) } }
            scriptPath('ci/jenkins/jenkinsfiles/seed_k8s.groovy')
            lightweight(true)
        }
    }
}
