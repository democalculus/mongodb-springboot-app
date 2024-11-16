//${library.jenkins-slack-library.version}
@Library('Slack-us-east-jenkins-master_snow_prod') _

pipeline {

  agent { label 'eagunu-slave-agent' }

  options {
       buildDiscarder logRotator(
           artifactDaysToKeepStr: '5',
           artifactNumToKeepStr: '5',
           daysToKeepStr: '5',
           numToKeepStr: '5')
          timestamps()
        }

  tools {
      maven 'UI_Maven3..9.9'
  }

  environment {
    BUILD_NUMBER = "${env.BUILD_ID}"
    eagunu_pwd = 'eagunuworld_docker_hub_password'
    //eagunu docker registry repository
    registry = "eagunuworld/mongodb-springboot-application"
    //eagunu dockerhub registry
    registryCredential = 'eagunuworld-docker-username-and-pwd'
    dockerImage = ''
    //latest_version_update
    imageVersion = "eagunuworld/mongodb-springboot-application:v$BUILD_NUMBER"
    // This can be nexus3 or nexus2
    NEXUS_VERSION = "nexus3"
    // This can be http or https
    NEXUS_PROTOCOL = "http"
    // Where your Nexus is running
    NEXUS_URL = "18.216.167.207:8081"
    // Repository where we will upload the artifact
    NEXUS_REPOSITORY = "mongodb-springboot-application"
    // Jenkins credential id to authenticate to Nexus OSS
    NEXUS_CREDENTIAL_ID = "nexus-username-password-creds-demoshool"
    //ARTIFACT_VERSION = "${BUILD_NUMBER}"

     //invalid tag "eagunuworld/mss-maven-web-app:v1.1.1:20": invalid reference format
    //REGISTRY_CREDENTIAL = 'eagunuworld-docker-password-logins'
    //containerName = "devsecops-container"
    //serviceName = "devsecops-svc"
  //  imageName = "siddharth67/numeric-app:${GIT_COMMIT}"
     //jenkins_server_url = "http://3.143.147.204:8080/"
    //mss_web_app = "/increment/99"
  }

  stages {
    stage('Cloning Git') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master_snow_prod']], extensions: [], userRemoteConfigs: [[credentialsId: 'democalculus-github-login-creds', url: 'https://github.com/democalculus/mongodb-springboot-app.git']]])
            }
        }

    stage ('Build wep app war file') {
      steps {
      sh 'mvn clean package'
       }
    }
   //hardcoded in pom.xml file
    // stage ('SonarQubeReport') {
    //   steps {
    //   sh 'mvn clean package sonar:sonar'
    // }
    //  }

  stage ('SonarQube Plugin Report') {
       steps {
         withSonarQubeEnv('SonarQubeAccessToken') {
         sh "mvn clean package sonar:sonar"
          }
        }
      }

      stage("publish to nexus") {
          steps {
              script {
                  // Read POM xml file using 'readMavenPom' step , this step 'readMavenPom' is included in: https://plugins.jenkins.io/pipeline-utility-steps
                  pom = readMavenPom file: "pom.xml";
                  // Find built artifact under target folder
                  filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                  // Print some info from the artifact found
                  echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                  // Extract the path from the File found
                  artifactPath = filesByGlob[0].path;
                  // Assign to a boolean response verifying If the artifact name exists
                  artifactExists = fileExists artifactPath;

                  if(artifactExists) {
                      echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";

                      nexusArtifactUploader(
                          nexusVersion: NEXUS_VERSION,
                          protocol: NEXUS_PROTOCOL,
                          nexusUrl: NEXUS_URL,
                          groupId: pom.groupId,
                          version: BUILD_NUMBER,
                          repository: NEXUS_REPOSITORY,
                          credentialsId: NEXUS_CREDENTIAL_ID,
                          artifacts: [
                              // Artifact generated such as .jar, .ear and .war files.
                              [artifactId: pom.artifactId,
                              classifier: '',
                              file: artifactPath,
                              type: pom.packaging]
                          ]
                      );

                  } else {
                      error "*** File: ${artifactPath}, could not be found";
                  }
              }
             }
         }

      stage('Building our image') {
           steps{
                script {
                   dockerImage = docker.build registry + ":v$BUILD_NUMBER"
                  }
              }
           }

      // stage('QA approve') {
      //        steps {
      //          notifySlack("Do you approve QA deployment? $registry/job/$BUILD_NUMBER", [])
      //            input 'Do you approve QA deployment?'
      //            }
      //        }

      stage('Deploy our image') {
         steps{
             script {
                docker.withRegistry( '', registryCredential ) {
               dockerImage.push()
              }
            }
           }
         }

    stage('updating image version') {
          steps {
                sh "bash update_image_version.sh"
                }
            }

    stage('DockerCleanUp ConfigMap') {
                 steps {
                   parallel(
                     "Cleaning up docker Images": {
                          sh 'docker rmi  ${imageVersion}'
                         },
                         "configureMap-Namespace": {
                           sh 'bash cmSecret-ns.sh'
                            }
                      )
                  }
            }

    stage('springboot Deployment') {
            steps {
              parallel(
                "Deployment": {
                     sh 'springboot_commands.sh'
                    },
                    "Rollout Status": {
                      sh 'bash springboot-rollout.sh'
                        },
                        "mongodb commands": {
                       sh 'bash mongodb_commands.sh'
                       }

                      )
                    }
                }

  // stage ('Deploying To EKS') {
  //      steps {
  //      sh 'kubectl apply -f mss-us-east-2-prod.yml'
  //      }
  //     }

 }  //This line end the pipeline stages
  post {   //This line start the post script
        always {
          //junit 'target/surefire-reports/*.xml'
         // jacoco execPattern: 'target/jacoco.exec'
        // pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
         //dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
         //publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report'])

         //Use sendNotifications.groovy from shared library and provide current build result as parameter
         sendNotification currentBuild.result
        }

    //success {
      //script {
        /* Use slackNotifier.groovy from shared library and provide current build result as parameter */
        //env.failedStage = "none"
        //env.emoji = ":white_check_mark: :tada: :thumbsup_all:"
        //sendNotification currentBuild.result
      //}
      //}

    // failure {
    //}
  }  //this line close post script stage
}    //This line close the jenkins pipeline
