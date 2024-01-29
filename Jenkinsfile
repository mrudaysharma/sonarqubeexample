pipeline {
    agent any
    
    environment {
        SONARQUBE_SERVER = 'http://localhost:9000'  // Replace with your SonarQube server URL
        ROCKETCHAT_WEBHOOK_URL = 'http://localhost:3000/hooks/65b6913ae19a180e8ec222ab/uhnJHuEmmS7PyFiD4xGChPg5Loam2LqxDn5fLNqLokiuWahJ'  // Replace with your Rocket.Chat webhook URL
        REPO_URL = 'https://github.com/mrudaysharma/sonarqubeexample.git'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                        dir("${WORKSPACE}")
                        {
                            def repoExists = fileExists('.git')
                            if (repoExists) {
                                 echo "Repository already exists, skipping clone step."
                            } else {
                              withCredentials([string(credentialsId: 'GitHubAccessToken', variable: 'GITHUB_TOKEN')]) {
                              sh "git clone ${REPO_URL}"
                            }
                        }
                       }
                    }
            }
        }

        stage("Build Artefact") {
                 steps {
                 dir("${WORKSPACE}/Calculator") {
                      withSonarQubeEnv('sonarqube') {
                           cho "Building master"
                           sh "mvn clean install sonar:sonar"
                           junit testResults: '**/target/*-reports/TEST-*.xml'
                           // publish the JACOCO result
                           jacoco(execPattern: 'target/jacoco.exec')
                           }
                     }
                      }
                 }

            stage("Quality Check") {
                   steps {
                       timeout(time: 3, unit: 'MINUTES') {
                             waitForQualityGate abortPipeline: true
                             }
                       }
                   }

        stage('Send Report to Rocket.Chat') {
            steps {
                script {
                    def reportText = "SonarQube analysis is complete! [View Report](${SONARQUBE_SERVER}/dashboard?id=${env.JOB_NAME})"

                    def payload = [
                        text: reportText,
                        channel: 'YOUR_ROCKETCHAT_CHANNEL',  // Replace with your Rocket.Chat channel
                    ]

                    def response = httpRequest(
                        acceptType: 'APPLICATION_JSON',
                        contentType: 'APPLICATION_JSON',
                        httpMode: 'POST',
                        requestBody: jsonToString(payload),
                        url: ROCKETCHAT_WEBHOOK_URL
                    )

                    if (response.status != 200) {
                        error "Failed to send report to Rocket.Chat: HTTP ${response.status}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
