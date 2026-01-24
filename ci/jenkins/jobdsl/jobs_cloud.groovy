def repoUrl = 'https://github.com/it2022031/DevOps-2025.git'
def branch  = '*/main'
def gitCreds = null // βάλε credentialsId αν χρειαστεί

pipelineJob('ping-cloud') {
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url(repoUrl)
                        if (gitCreds) { credentials(gitCreds) }
                    }
                    branches(branch)
                }
            }
            scriptPath('ci/jenkins/jenkinsfiles/cloud_ping_vms.groovy')
            lightweight(true)
        }
    }
}
pipelineJob('deploy-vms-online-nginx') {
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url(repoUrl)
                        if (gitCreds) { credentials(gitCreds) }
                    }
                    branches(branch)
                }
            }
            scriptPath('ci/jenkins/jenkinsfiles/deploy_vms_online_nginx.groovy')
            lightweight(true)
        }
    }
}
pipelineJob('deploy-k8s-online-nginx') {
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url(repoUrl)
                        if (gitCreds) { credentials(gitCreds) }
                    }
                    branches(branch)
                }
            }
            scriptPath('ci/jenkins/jenkinsfiles/deploy_k8s_online_nginx.groovy')
            lightweight(true)
        }
    }
}