def testOutput = ""
def sendEmail(job_name, job_id, job_status, output) {
    if (job_status == "SUCCESS") {
        echo (message: "Job: ${job_name} (ID: ${job_id}) je uspjesno prosao!")
    } else if (job_status == "UNSTABLE") {
        echo (message: "Job: ${job_name} (ID: ${job_id}) je uspjesno zavrsen, ali postoje neki testovi koji su pali!")
    } else {
        echo (message: "Job: ${job_name} (ID: ${job_id}) je pao!")
    }
    echo (message: "Tests outputs: ${output}")
}

pipeline {
    agent any
    
    parameters {
        string defaultValue: 'pipeline.zip',
        description: 'Artifact name',
        name: 'ARTIFACT_NAME',
        trim: true
        
        booleanParam description: 'Make build fail if set',
        name: 'FAIL'

        booleanParam description: 'Run test',
        name: 'RUN_TEST'
    }

    stages {
        stage('Clean') {
            steps {
                echo (message: 'Clean')
                cleanWs()
            }
        }
        stage('Download') {
            steps {
                echo (message: 'Download')
                dir ('pipeline') {
                    git (
                        branch: 'pipeline',
                        url: 'https://github.com/KLevon/jenkins-course'
                    )
                }
                rtDownload(
                    serverId: 'Artifactory',
                    spec: '''{
                        "files": [
                         {
                             "pattern": "generic-local/libraries/printer.zip",
                             "target": "printer/",
                             "flat": "true"
                         }
                        ]
                    }'''
                )
                unzip (
                    zipFile: "printer/printer.zip",
                    dir: "pipeline/"
                )
            }
        }
        stage('Build') {
            steps {
                echo (message: 'Build')
                withCredentials (
                    [usernamePassword(credentialsId: 'DUMMY', passwordVariable: 'pwd', usernameVariable: 'usr')]
                ) {
                    echo (message: "Credentials used: username - ${usr}, password - ${pwd}")
                }
                bat (
                    script: """
                        cd pipeline
                        Makefile.bat
                        cd ..
                    """
                )
                script {
                    zip (
                        zipFile: "${params.ARTIFACT_NAME}",
                        archive: true,
                        dir: "pipeline/",
                        glob: "hello_world.exe"
                    )
                }
            }
        }
        stage('Test') {
            when {
                equals expected: true,
                actual: params.RUN_TEST
            }
            steps {
                echo (message: "Test step started")
                script {
                    def modules = ["printer", "scanner", "main"]
                    
                    for (module in modules) {
                        testOutput += bat (
                                            script: """
                                                cd pipeline
                                                Tests.bat ${module}
                                                cd ..
                                            """,
                                            returnStdout: true
                        ).trim()
                    }
                }
                
            }
        }
        stage('Publish') {
            steps {
                echo (message: 'Publish')
                rtUpload(
                    serverId: 'Artifactory',
                    spec: """{
                        "files": [
                            {
                              "pattern": "${params.ARTIFACT_NAME}",
                              "target": "generic-local/vanja/${env.BUILD_ID}/${params.ARTIFACT_NAME}"
                            }
                        ]
                    }"""
                )
                script {
                    if (params.FAIL == true) {
                        bat (
                            script: """
                                exit 1
                            """
                        )
                    }
                }
            }
        }
    }
    post {
        success {
            script {
                    sendEmail(env.JOB_NAME, env.BUILD_ID, "SUCCESS", testOutput)
                }
        }
        failure {
            script {
                    sendEmail(env.JOB_NAME, env.BUILD_ID, "FAILURE", testOutput)
                }
        }
        unstable {
            script {
                    sendEmail(env.JOB_NAME, env.BUILD_ID, "UNSTABLE", testOutput)
                }
        }
    }
}
