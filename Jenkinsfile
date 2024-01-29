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

                               sh 'mvn sonar:sonar \
                                     -Dsonar.projectKey=MyCalculatorKey \
                                     -Dsonar.host.url=http://sonarqube:9000 \
                                     -Dsonar.login=sqp_3e454e2ed0f3bf0342473701341abd2bf34d38fd'

                       }
                       }
                   }
               }
               stage("Quality Gate") {
                   steps {
                       timeout(time: 1, unit: 'HOURS') {
                           // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                           // true = set pipeline to UNSTABLE, false = don't
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
