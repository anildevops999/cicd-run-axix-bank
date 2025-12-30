pipeline {
    agent any

    /* =========================
       BUILD PARAMETER
       ========================= */
    parameters {
        choice(
            name: 'DEPLOY_ENV',
            choices: ['dev', 'pp', 'prod'],
            description: 'Select environment to deploy'
        )
    }

    /* =========================
       GLOBAL VARIABLES
       ========================= */
    environment {
        DOCKER_HUB_USER = 'afroz2022'
        IMAGE_NAME = 'cloudrunlab123'
        REGION = 'us-central1'
    }

    stages {

        /* =========================
           ENVIRONMENT SETUP
           ========================= */
        stage('Set Environment') {
            steps {
                script {
                    if (params.DEPLOY_ENV == 'dev') {
                        env.PROJECT_ID  = 'resolute-bloom-476105-f9'
                        env.SERVICE_NAME = 'cloudrunlab123'
                    }
                    else if (params.DEPLOY_ENV == 'pp') {
                        env.PROJECT_ID  = 'resolute-bloom-476105-f9'
                        env.SERVICE_NAME = 'cloudrunlab123'
                    }
                    else if (params.DEPLOY_ENV == 'prod') {
                        env.PROJECT_ID  = 'resolute-bloom-476105-f9'
                        env.SERVICE_NAME = 'resolute-bloom-476105-f9'
                    }

                    echo "Deploying to ${params.DEPLOY_ENV.toUpperCase()}"
                }
            }
        }

        /* =========================
           CLONE SOURCE
           ========================= */
        stage('Clone Repository') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/anildevops999/cicd-run-axix-bank.git'
            }
        }

        /* =========================
           BUILD IMAGE
           ========================= */
        stage('Build Docker Image') {
            steps {
                sh """
                    docker build \
                    -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER} .
                """
            }
        }

        /* =========================
           PUSH IMAGE
           ========================= */
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
                        docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}
                    """
                }
            }
        }

        /* =========================
           PROD APPROVAL
           ========================= */
        stage('Approval for Prod') {
            when {
                expression { params.DEPLOY_ENV == 'prod' }
            }
            steps {
                input message: 'Approve deployment to PRODUCTION', ok: 'Deploy'
            }
        }

        /* =========================
           DEPLOY TO CLOUD RUN
           ========================= */
        stage('Deploy to Cloud Run') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'gcp-service-account',
                        variable: 'GOOGLE_APPLICATION_CREDENTIALS'
                    )
                ]) {
                    sh """
                        gcloud auth activate-service-account \
                            --key-file=$GOOGLE_APPLICATION_CREDENTIALS

                        gcloud config set project ${PROJECT_ID}

                        gcloud run deploy ${SERVICE_NAME} \
                            --image docker.io/${DOCKER_HUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER} \
                            --platform managed \
                            --region ${REGION} \
                            --allow-unauthenticated
                    """
                }
            }
        }

        /* =========================
           CLEANUP
           ========================= */
        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }
    }
}
