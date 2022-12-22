@Library('shared-mss') _

pipeline{

  agent{
      label "node01"
       }

    options {
      buildDiscarder logRotator(
        artifactDaysToKeepStr: '1',
        artifactNumToKeepStr: '2',
        daysToKeepStr: '1',
        numToKeepStr: '2')
      timestamps()
     }

  parameters {
       choice choices: ['main','walmart-mongodb-dev-mss'], description: 'This is choice paramerized job', name: 'BranchName'
       string defaultValue: 'Eghosa DevOps', description: 'please developer select the person\' name', name: 'personName'
     }

    tools{
         maven 'demo-maven:3.8.6'
          }
    environment {
              DEPLOY = "${env.BRANCH_NAME == "python-dramed" || env.BRANCH_NAME == "master" ? "true" : "false"}"
              NAME = "${env.BRANCH_NAME == "python-dramed" ? "example" : "example-staging"}"
              //def mvnHome =  tool name: "demo-maven:3.8.6", type: "maven"
              //def mavenCMD = "${mavenHome}/usr/share/maven"
              VERSION = "${env.BUILD_ID}"
              BUILD_NUMBER = "${env.BUILD_NUMBER}"
              BRANCH_NAME = "${env.BRANCH_NAME}"
              NODE_NAME = "${env.NODE_NAME}"
              REGISTRY = 'eagunuworld/mongodb-springboot-app'
              REGISTRY_CREDENTIAL = 'eagunuworld_dockerhub_creds'
            }

    stages {

      // stage('Example') {
      //      if (env.BRANCH_NAME == 'python-dramed') {
      //            echo 'I only execute on this environment $env.BRANCH_NAME'
      //          } else {
      //               echo 'I execute elsewhere'
      //              }
      //           }
      stage('checking.. out codes ') {
          steps {
                git branch: "${params.BranchName}", credentialsId: 'democalculus_github_creds_ID', url: 'https://github.com/democalculus/mongodb-springboot-app.git'
                 //git (credentialsId: 'democalculus_github_creds_ID', url: 'https://github.com/democalculus/springboot-dockerimage',branch: 'walmart-dev-mss')
                   }
                }

      // stage(" Maven buld Artifacts Package"){
      //             def mavenCMD = "${mavenHome}/bin/mvn"
      //             sh "${mavenCMD} clean package"
      //           }

      //Run Junt Test cases & Do the Build

    stage('RunUnitTestcases&Build'){
              steps{
                  parallel(
                        RunUnitTestCases: {
                             sh "mvn test"
                          },

                Build: {
                       sh "mvn clean package"
                         }
                     )
                  }
            }

  stage ('Code coverage failed without build marked')  {
                  steps {
                    jacoco(
                      deltaBranchCoverage: '80',
                      deltaClassCoverage: '80',
                      deltaComplexityCoverage: '80',
                      deltaInstructionCoverage: '80',
                      deltaLineCoverage: '80',
                      deltaMethodCoverage: '80',
                      maximumBranchCoverage: '80',
                      maximumClassCoverage: '80',
                      maximumComplexityCoverage: '80',
                      maximumInstructionCoverage: '80',
                      maximumLineCoverage: '80',
                      maximumMethodCoverage: '80',
                      minimumBranchCoverage: '80',
                      minimumClassCoverage: '80',
                      minimumComplexityCoverage: '80',
                      minimumInstructionCoverage: '80',
                      minimumLineCoverage: '80',
                      minimumMethodCoverage: '80'
                       )
                  }
              }

    // stage('nexusArtifactUploader') {
    //         steps {
    //           nexusArtifactUploader(
    //           nexusVersion: 'nexus3',
    //           protocol: 'http',
    //           nexusUrl: '10.182.0.3:8081',
    //           //groupId: 'myGroupId',
    //           groupId: 'walmart-dev',
    //           version: '1.0-SNAPSHOT',
    //           repository: 'eagunu-mvn-snapshot-mss',
    //           credentialsId: 'nexus_creds_id',
    //           artifacts: [
    //               [artifactId: 'maven-web-app',
    //                classifier: '',
    //                file: 'maven-web-app/target/maven-web-app.war',
    //                type: 'war']
    //                ]
    //             )
    //          }
    //       }


  stage('Building Docker Images') {
          steps {
              sh "docker build -t ${REGISTRY}:${VERSION} ."
                  }
              }

    stage('Push Docker Image To DockerHub') {
          steps {
                   withCredentials([string(credentialsId: 'eagunuworld_dockerhub_creds', variable: 'eagunuworld_dockerhub_creds')])  {
                   sh "docker login -u eagunuworld -p ${eagunuworld_dockerhub_creds} "
                   }
                 sh 'docker push ${REGISTRY}:${VERSION}'
                }
             }
    stage('Display All Running Images') {
            steps {
               sh 'docker images'
            }
          }

  stage('Update docker-compose Tag'){
      steps{
          	script{
          				    sh '''final_tag=$(echo $VERSION | tr -d ' ')
          				     echo ${final_tag}test
          				     sed -i "s/BUILD_TAG/$final_tag/g"  docker-compose.yml
          				     '''
          				  }
          			 }
          		}
  stage('Display docker-compose content ') {
        steps {
            sh 'cat docker-compose.yml'
            }
        }

  stage('Stop And Remove previous Running Container') {
      steps{
          sshagent(['ec2-user-password-credentials']) {
               sh 'docker ps -f name=springboot -q | xargs --no-run-if-empty docker container stop'
               sh 'docker container ls -a -fname=springboot  -q | xargs -r docker container rm'
               sh 'docker container ls '
                  }
                }
             }

  stage('Remove All Images Before Deployment') {
           steps{
               sshagent(['node01-jenkins-connection']) {
                  sh 'docker rmi  $(docker images -q)'
                  }
               }
          }

 stage('Deploy On Prod') {
     steps{
       sshagent(['node01-jenkins-connection']) {
            sh "scp -o StrictHostKeyChecking=no docker-compose.yml makutaworldmpm@10.206.0.2:"
            sh "ssh -o StrictHostKeyChecking=no makutaworldmpm@10.206.0.2 docker-compose up -d"
           }
         }
      }
 //  stage('Remove ps from Agent Server') {
 //        steps {
 //              sh 'docker ps -f name=framed -q | xargs --no-run-if-empty docker container stop'
 //              sh 'docker container ls -a -fname=framed  -q | xargs -r docker container rm'
 //              sh 'docker container ls '
 //                }
 //            }

   }// stages blocks closed
   post {
       aborted {
           slackcodenotifications(currentBuild.result)
            }
     success {
          slackcodenotifications(currentBuild.result)
         }
    failure  {
        slackcodenotifications(currentBuild.result)
      }
   }
}//pipeline closed



//slack notifications blocks
// def slackNotifications(String buildStatus = 'STARTED') {
//   // build status of null means successful
//   buildStatus =  buildStatus ?: 'SUCCESS'
//   //buildStatus = buildStatus ? "SUCCESS":"FAILURE"
//
//   // Default values
//   def colorName = 'RED'
//   def colorCode = '#FF0000'
//   def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
//   def summary = "${subject} (${env.BUILD_URL})"
//
//   // Override default values based on build status
//   if (buildStatus == 'STARTED') {
//     colorName = 'ORANGE'
//     colorCode = '#FFA500'
//   } else if (buildStatus == 'SUCCESS') {
//     colorName = 'GREEN'
//     colorCode = '#00FF00'
//   } else {
//     colorName = 'RED'
//     colorCode = '#FF0000'
//   }
//
//   // Send notifications
//   slackSend (color: colorCode, message: summary, channel: "#walmart")
// }
