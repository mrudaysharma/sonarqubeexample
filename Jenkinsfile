import groovy.json.JsonOutput

pipeline {
    agent any
    tools {
        maven 'maven3.9.6'
      }
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


       stage('build && SonarQube analysis') {
                   steps {
                    dir("${WORKSPACE}/Calculator") {
                       withSonarQubeEnv('SonarServer') {
                           // Optionally use a Maven environment you've configured already

                               sh 'mvn sonar:sonar -Dsonar.host.url=http://sonarqube:9000'

                       }
                       }
                   }
               }

                    stage("Quality Gate") {
                        steps {
                            timeout(time: 5, unit: 'MINUTES') {
                                script {
                                    // Wait for SonarQube's quality gate result
                                    sleep(10) // Consider removing this if it's not necessary
                                    def qg = waitForQualityGate() // This will return a result object
                                    // Store the quality gate status for use in later stages or post block
                                    env.qualityGateStatus = qg.status
                                }
                            }
                        }
                    }

                    stage("Send Report to Rocket.Chat") {
                        steps {
                            script {
                                // Prepare the report text based on the quality gate status
                                def statusMessage = (env.qualityGateStatus == 'OK') ? "passed" : "failed"
                                def reportText = "SonarQube analysis is complete and the quality gate has ${statusMessage}! [View Report](${SONARQUBE_SERVER}/dashboard?id=${env.JOB_NAME})"

                                def payload = [
                                    text: reportText,
                                    channel: '#JenkinsPipeline'  // Replace with your Rocket.Chat channel
                                ]
                                    def jsonPayload = JsonOutput.toJson(payload)

                                    def response = httpRequest(
                                        acceptType: 'APPLICATION_JSON',
                                        contentType: 'APPLICATION_JSON',
                                        httpMode: 'POST',
                                        requestBody: jsonPayload,
                                        url: ROCKETCHAT_WEBHOOK_URL,
                                        timeout: 120000
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

