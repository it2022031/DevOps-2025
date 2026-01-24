// Job DSL (cloud): creates pipeline jobs from SCM (this repo)

def repoUrl = 'https://github.com/it2022031/DevOps-2025.git'
def branch  = '*/main'

// Αν το repo είναι PRIVATE, βάλε credentialsId και δημιουργησέ το στο Jenkins (Manage Credentials)
// def gitCreds = 'github-creds-id'   // <- άλλαξε το
def gitCreds = null

def cpsScmDef = { String scriptPath ->
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

// (Optional) Folder για να είναι μαζεμένα
folder('DS-2025') {
    displayName('DS-2025')
    description('Pipelines for DevOps-2025 / DS-2025 project')
}

// 1) infra-check
pipelineJob('DS-2025/infra-check') {
    definition { cpsScmDef('ci/jenkins/jenkinsfiles/test.groovy') }
}

// 2) deploy targets
pipelineJob('DS-2025/deploy-vms') {
    definition { cpsScmDef('ci/jenkins/jenkinsfiles/deploy_vms.groovy') }
}

pipelineJob('DS-2025/deploy-docker') {
    definition { cpsScmDef('ci/jenkins/jenkinsfiles/deploy_docker.groovy') }
}

pipelineJob('DS-2025/deploy-k8s') {
    definition { cpsScmDef('ci/jenkins/jenkinsfiles/deploy_k8s.groovy') }
}

// 3) build/push images
pipelineJob('DS-2025/build-push-images') {
    definition { cpsScmDef('ci/jenkins/jenkinsfiles/build_push_images.groovy') }
}

// 4) seed data jobs
pipelineJob('DS-2025/seed-vms') {
    definition { cpsScmDef('ci/jenkins/jenkinsfiles/seed_vms.groovy') }
}

pipelineJob('DS-2025/seed-docker') {
    definition { cpsScmDef('ci/jenkins/jenkinsfiles/seed_docker.groovy') }
}

pipelineJob('DS-2025/seed-k8s') {
    definition { cpsScmDef('ci/jenkins/jenkinsfiles/seed_k8s.groovy') }
}
