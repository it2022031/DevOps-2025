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
pipelineJob('deploy-docker-online-nginx') {
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
            scriptPath('ci/jenkins/jenkinsfiles/deploy_docker_online_nginx.groovy')
            lightweight(true)
        }
    }
}
pipelineJob('seed-vms-online') {
    definition {
        cpsScm {
            scm {
                git {
                    remote { url(repoUrl); if (gitCreds) { credentials(gitCreds) } }
                    branches(branch)
                }
            }
            scriptPath('ci/jenkins/jenkinsfiles/seed_vms_online.groovy')
            lightweight(true)
        }
    }
}

pipelineJob('load-photos-vms-online') {
    definition {
        cpsScm {
            scm {
                git {
                    remote { url(repoUrl); if (gitCreds) { credentials(gitCreds) } }
                    branches(branch)
                }
            }
            scriptPath('ci/jenkins/jenkinsfiles/load_photos_vms_online.groovy')
            lightweight(true)
        }
    }
}

pipelineJob('build-push-images-online') {
    definition {
        cpsScm {
            scm {
                git {
                    remote { url(repoUrl); if (gitCreds) { credentials(gitCreds) } }
                    branches(branch)
                }
            }
            scriptPath('ci/jenkins/jenkinsfiles/build_push_images_online.groovy')
            lightweight(true)
        }
    }
}