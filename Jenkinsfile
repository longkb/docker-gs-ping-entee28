pipeline {
    agent none

    tools { go 'go' }

    stages {
        stage('Cache stage') {
            agent any

            environment {
                CI_PROJECT_DIR = "${env.WORKSPACE}"
            }

            steps {
                sh 'go env -w GOMODCACHE=$CI_PROJECT_DIR/cache/modcache'
                sh 'go env -w GOCACHE=$CI_PROJECT_DIR/cache/buildcache'

                cache(maxCacheSize: 250, defaultBranch: 'main', caches: [
                    arbitraryFileCache(
                        path: 'cache',
                        cacheValidityDecidingFile: 'go.sum'
                    )
                ]) {
                    sh 'go mod download'
                }
            }
        }

        stage('Build Docker Image with Kaniko') {
            agent {
                kubernetes {
                    defaultContainer 'kaniko'
                    yamlFile 'k8s/kaniko.yaml'
                }
            }

            environment {
                CI_PROJECT_DIR = "${env.WORKSPACE}"
            }

            steps {
                cache(maxCacheSize: 250, defaultBranch: 'main', caches: [
                    arbitraryFileCache(
                        path: 'cache',
                        cacheValidityDecidingFile: 'go.sum'
                    )
                ]) {
                    sh '''#!/busybox/sh
                        /kaniko/executor \
                        --cache=true \
                        --use-new-run \
                        --snapshot-mode=redo \
                        --context $CI_PROJECT_DIR \
                        --dockerfile $CI_PROJECT_DIR/Dockerfile \
                        --verbosity debug \
                        --build-arg CI_PROJECT_DIR=$CI_PROJECT_DIR \
                        --destination thachthucregistry.azurecr.io/minimal-go:latest \
                    '''
                }
            }
        }
    }
}
