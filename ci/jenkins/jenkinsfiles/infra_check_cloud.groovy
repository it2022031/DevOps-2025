def repoUrl = 'https://github.com/it2022031/DevOps-2025.git'
def branch  = '*/main'

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
