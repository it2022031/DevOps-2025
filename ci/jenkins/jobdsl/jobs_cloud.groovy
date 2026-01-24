def repoUrl = 'https://github.com/it2022031/DevOps-2025.git'
def branch  = '*/main'

// Αν χρειαστεί για private repo, βάλε credentialsId εδώ:
def gitCreds = null
// def gitCreds = 'github-creds-id'

folder('DS-2025') {
    displayName('DS-2025')
    description('Pipelines for DevOps-2025 / DS-2025 project')
}

def makePipelineJob = { String name, String scriptPath ->
    pipelineJob(name) {
        definition {
            cpsScm {
                scm {
                    git {
                        remote {
                            url(repoUrl)
                            if (gitCreds) {
                                credentials(gitCreds)
                            }
                        }
                        branches(branch)
                    }
                }
                scriptPath(scriptPath)
                lightweight(true)
            }
        }
    }
}

// Jobs
makePipelineJob('DS-2025/infra-check',       'ci/jenkins/jenkinsfiles/test.groovy')
makePipelineJob('DS-2025/deploy-vms',        'ci/jenkins/jenkinsfiles/deploy_vms.groovy')
makePipelineJob('DS-2025/deploy-docker',     'ci/jenkins/jenkinsfiles/deploy_docker.groovy')
makePipelineJob('DS-2025/deploy-k8s',        'ci/jenkins/jenkinsfiles/deploy_k8s.groovy')
makePipelineJob('DS-2025/build-push-images', 'ci/jenkins/jenkinsfiles/build_push_images.groovy')
makePipelineJob('DS-2025/seed-vms',          'ci/jenkins/jenkinsfiles/seed_vms.groovy')
makePipelineJob('DS-2025/seed-docker',       'ci/jenkins/jenkinsfiles/seed_docker.groovy')
makePipelineJob('DS-2025/seed-k8s',          'ci/jenkins/jenkinsfiles/seed_k8s.groovy')
