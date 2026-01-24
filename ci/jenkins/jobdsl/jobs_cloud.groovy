def repoUrl = 'https://github.com/it2022031/DevOps-2025.git'
def branch  = '*/main'

// Αν είναι private repo, βάλε credentialsId εδώ (αλλιώς άστο null)
def gitCreds = null
// def gitCreds = 'github-creds-id'

folder('DS-2025') {
    displayName('DS-2025')
    description('Pipelines for DevOps-2025 / DS-2025 project')
}

pipelineJob('DS-2025/ping-vms') {
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
            scriptPath('ci/jenkins/jenkinsfiles/ping_vms.groovy')
            lightweight(true)
        }
    }
}
