def repoUrl = 'https://github.com/it2022031/DevOps-2025.git'
def branch  = '*/main'

// αν χρειαστεί private repo:
// def gitCreds = 'github-creds-id'
def gitCreds = null

pipelineJob('ping-vms') {
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
