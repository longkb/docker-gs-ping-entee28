pipeline {
    agent none

    stages {
        stage('Build Docker Image with Kaniko') {
            agent {
                kubernetes {
                    defaultContainer 'kaniko'
                    yamlFile 'k8s/kaniko.yaml'
                }
            }

            environment {
                PATH = "/busybox:/kaniko:$PATH"
                CI_PROJECT_DIR = "${env.WORKSPACE}"
            }

            steps {
                sh '''#!/busybox/sh
                    /kaniko/executor \
                    --cache=true \
                    --use-new-run \
                    --snapshot-mode=redo \
                    --context $CI_PROJECT_DIR \
                    --dockerfile $CI_PROJECT_DIR/Dockerfile \
                    --verbosity debug \
                    --destination thachthucregistry.azurecr.io/minimal-go:latest \
                '''
            }
        }
    }
}
