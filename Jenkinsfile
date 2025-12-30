pipeline {
    agent any

    parameters {
        choice(
            name: 'DEPLOY_ENV',
            choices: ['dev', 'pp', 'prod'],
            description: 'Select environment to deploy'
        )
    }

    environment {
        DOCKER_HUB_CREDENTIALS_USR = 'afroz2022'
        IMAGE_NAME = 'cloudrunlab123'
        REGION = 'us-central1'
    }

    stages {

        stage('Set Environment Config') {
            steps {
                script {
                    if (params.DEPLOY_ENV == 'dev') {
                        env.PROJECT_ID = 'resolute-bloom-dev'
                        env.SERVICE_NAME = 'cloudrunlab123-dev'
                    } else if (params.DEPLOY_ENV == 'pp') {
                        env.PROJECT_ID = 'resolute-bloom-pp'
                        env.SERVICE_NAME = 'cloudrunlab123-pp'
                    } else if (params.DEPLOY_ENV == 'prod') {
                        env.PROJECT_ID = 'resolute-bloom-prod'
                        env.SERVICE_NAME = 'cloudrunlab123-prod'
                    }
                }
            }
        }

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/anildevops999/cicd-run-axix-bank.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-hub-password',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh """
                        echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                        docker push ${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Approval for Prod') {
            when {
                expression { params.DEPLOY_ENV == 'prod' }
            }
            steps {
                input message: 'Deploy to PRODUCTION?', ok: 'Deploy'
            }
        }

        stage('Deploy to Cloud Run') {
            steps {
                withCredentials([
                    file(credentialsId: 'gcp-service-account', variable: 'GOOGLE_APPLICATION_CREDENTIALS')
                ]) {
                    sh """
                        gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                        gcloud config set project ${PROJECT_ID}

                        gcloud run deploy ${SERVICE_NAME} \
                            --image docker.io/${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:${BUILD_NUMBER} \
                            --platform managed \
                            --region ${REGION} \
                            --allow-unauthenticated
                    """
                }
            }
        }

        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }
    }
}
