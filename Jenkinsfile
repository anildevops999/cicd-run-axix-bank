pipeline {
    agent any 

    environment {
        PROJECT_ID = 'resolute-bloom-476105-f9'  // GCP Project ID
        DOCKER_HUB_CREDENTIALS_USR = 'afroz2022'  // Your Docker Hub username
        IMAGE_NAME = 'cloudrunlab'  // Docker image name
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/kumar-devops999/cloudrun-cicd.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-password', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                        sh "docker push ${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:${BUILD_NUMBER}"
                    }
                }
            }
        }

        stage('Deploy to Google Cloud Run') {
            steps {
                script {
                    // Authenticate with GCP using the service account key file stored in Jenkins credentials
                    withCredentials([file(credentialsId: 'gcp-service-account', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {

                        // Explicitly activate the service account
                        sh "gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS"

                        // Set the project
                        sh "gcloud config set project ${PROJECT_ID}"

                        // Deploy to Cloud Run
                        sh """
                            gcloud run deploy ${IMAGE_NAME} \
                                --image docker.io/${DOCKER_HUB_CREDENTIALS_USR}/${IMAGE_NAME}:${BUILD_NUMBER} \
                                --platform managed \
                                --region us-central1 \
                                --allow-unauthenticated
                        """

                        // Allow public access (if needed)
                        sh """
                            gcloud run services add-iam-policy-binding ${IMAGE_NAME} \
                                --region us-central1 \
                                --member='allUsers' \
                                --role='roles/run.invoker'
                        """
                    }
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
