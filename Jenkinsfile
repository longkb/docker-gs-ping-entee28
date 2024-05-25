podTemplate(yaml: readTrusted('k8s/kaniko.yaml')) {
  node(POD_LABEL) {
    stage('Build Docker Image with Dind'){
        container('jnlp') {
            sh '''
                set -ex
                ls -la
                pwd
                whoami
                touch "test.txt"
                echo "jnlp"
            '''
        }
        container('dind') {
            sh '''
                set -ex
                ls -la
                echo "dind"
                pwd
                whoami
                docker pull longkb/argocd-backup
            '''
        }

    }
  }
}
