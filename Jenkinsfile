pipeline {
    agent none

    stages {
        stage('Build Docker Image with Kaniko') {
            agent {
                kubernetes {
                    defaultContainer 'docker'
                    yamlFile 'k8s/kaniko.yaml'
                }
            }
            steps {
                sh '''
                    docker pull longkb/argocd-backup
                '''
            }
        }
    }
}
