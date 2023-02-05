@Library('shared-mss') _

pipeline{

  agent{
      label "kubeadm-master"
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
       choice choices: ['main','walmart-mongodb-dev-mss', "mss-walmart-prod"], description: 'This is choice paramerized job', name: 'BranchName'
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

    stage('package And CodeCoverage') {
           steps {
             parallel(
               "BuildPackage": {
                   sh "mvn clean package"
                   archive 'target/*.jar'
                 },
               "Jacoco coverate": {
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
                 },
               "Build Docker Image": {
                   sh "docker build -t ${REGISTRY}:${VERSION} ."
                 }
             )
           }
         } 
   
     stage('unkown') {
           steps {
             parallel(
               "Login And Push Image": {
                   withCredentials([string(credentialsId: 'eagunuworld_dockerhub_creds', variable: 'eagunuworld_dockerhub_creds')])  {
                   sh "docker login -u eagunuworld -p ${eagunuworld_dockerhub_creds} "
                   }
                   sh 'docker push ${REGISTRY}:${VERSION}'
                  },
                "Display All Running Images": {
                  sh 'docker images'
                 }
             )
           }
         } 

  stage('Update deployment image Tag And cat'){
      steps{
        parallel(
           "runing": {
              script{
          				    sh '''final_tag=$(echo $VERSION | tr -d ' ')
          				     echo ${final_tag}test
          				     sed -i "s/BUILD_TAG/$final_tag/g"  deployment_dev.yml
          				     '''
          				  }
                },
               "Update Image latest": {
                  sh 'cat deployment_dev.yml'
                 }
              )
          	}
          }

  // stage('Display deployment content after update ') {
  //       steps {
  //           sh 'cat deployment_dev.yml'
  //           }
  //       }

  // stage('Stop And Remove previous Running Container') {
  //     steps{
  //         sshagent(['ec2-user-password-credentials']) {
  //              sh 'docker ps -f name=springboot -q | xargs --no-run-if-empty docker container stop'
  //              sh 'docker container ls -a -fname=springboot  -q | xargs -r docker container rm'
  //              sh 'docker container ls '
  //                 }
  //               }
  //            }

  stage('Remove All Images Before Deployment') {
           steps{
               sshagent(['node01-jenkins-connection']) {
                  sh 'docker rmi  $(docker images -q)'
                  }
               }
          }
   
   stage('K8S Deployment - DEV') {
           steps {
             parallel(
               "Deployment": {
                   sh "kubectl apply -f deployment_dev.yml"
                 },
               "Rollout Status": {
                   sh "kubectl apply -f deployment_prod.yml"
                 }
             )
           }
         } 

    // stage ('Approver Needed To Deploy On Prod')  {
    //         steps {
    //           echo "Taking approval from QA manager"
    //           timeout(time: 7, unit: 'DAYS') {
    //           input message: 'Do you want to proceed to PROD Deploy?', submitter: 'admin,manager_userid'
    //          }
    //         }
    //       }

   }// stages blocks closed
}