pipeline {
    agent { label 'pytester' }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Setup Python Environment') {
            steps {
                container ('python') {
                    sh '''
                    python3 -m venv myenv
                    . myenv/bin/activate
                    pip install -r requirements.txt
                    '''
                }
            }
        }
        stage('Run Tests') {
            steps {
                container ('python') {
                    // replace pipeline with the name of your pipeline
                    sh '''
                    . myenv/bin/activate
                    export PYTHONPATH=$PYTHONPATH:/home/jenkins/agent/workspace/pipeline
                    pytest tests
                    '''
                }
            }
        }
        stage('Build') {
            steps {
                container ('python') {
                    sh 'echo "In a real project, this might be where you package your Python app"'
                }
            }
        }
        stage('Deploy') {
            steps {
                container ('python') {
                    sh 'echo "Deploying application (simulated)"'
                    // In a real project, add deployment scripts here
                }
            }
        }
    }
    post {
        success {
            script {
                setBuildStatus('Build successful', 'SUCCESS')
            }
        }
        failure {
            script {
                setBuildStatus('Build failed', 'FAILURE')
            }
        }
    }
}

// Define the function to set build status
void setBuildStatus(String message, String state) {
    def repo = 'https://github.com/ssstier/workflow'

    step([
        $class: 'GitHubCommitStatusSetter',
        reposSource: [$class: 'ManuallyEnteredRepositorySource', url: repo],
        contextSource: [$class: 'ManuallyEnteredCommitContextSource', context: 'CI/Jenkins'],
        errorHandlers: [[$class: 'ChangingBuildStatusErrorHandler', result: 'UNSTABLE']],
        statusResultSource: [$class: 'ConditionalStatusResultSource', results: [
            [$class: 'AnyBuildResult', message: message, state: state]
        ]]
    ])
}
