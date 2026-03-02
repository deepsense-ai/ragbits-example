#!/bin/bash
set -e

# Configuration loading
source "$(dirname "$0")/../config.sh"

echo "Starting deployment for $APP_NAME..."
# GCP Authentication
gcloud config set project "$PROJECT_ID" --quiet

# creating bucket for Terraform state file storing
echo "Checking Terraform State Bucket..."
if ! gcloud storage buckets describe "gs://$TF_STATE_BUCKET" &>/dev/null; then
    echo "Creating bucket gs://$TF_STATE_BUCKET..."
    gcloud storage buckets create "gs://$TF_STATE_BUCKET" --location="$REGION" --project="$PROJECT_ID"
    gcloud storage buckets update "gs://$TF_STATE_BUCKET" --versioning
else
    echo "Bucket gs://$TF_STATE_BUCKET already exists."
fi

echo "Initializing Infrastructure..."
cd infrastructure/gcp/terraform
tofu init -reconfigure -backend-config="bucket=$TF_STATE_BUCKET"

# initializing Artifact Registry and Secret Manager
echo "Creating Artifact Registry and Secret Manager resources..."
tofu apply -target=google_artifact_registry_repository.repo \
           -target=google_secret_manager_secret.api_key \
           -var="project_id=$PROJECT_ID" \
           -var="region=$REGION" \
           -var="my_ip=${CURRENT_IP}/32" \
           -auto-approve

# Docker image & OpenAI key upload
echo "Uploading OpenAI API Key to Secret Manager..."
echo -n "$OPENAI_API_KEY" | gcloud secrets versions add openai-api-key --data-file=- --quiet

echo "Building and Pushing Docker Image..."
REPO_URL=$(tofu output -raw repository_url)
REGISTRY_HOST=$(echo "$REPO_URL" | cut -d'/' -f1)
echo "Detected Registry: $REGISTRY_HOST"

cd ../../.. # Go back to project root for docker build
# authenticate Docker specifically for this registry
gcloud auth configure-docker "$REGISTRY_HOST" --quiet

docker build -t "$REPO_URL/$APP_NAME:latest" .
docker push "$REPO_URL/$APP_NAME:latest"

# final tofu apply to deploy the Cloud Run service and related infra
echo "Deploying Cloud Run Service & Global Load Balancer..."
cd infrastructure/gcp/terraform

tofu apply -var="project_id=$PROJECT_ID" \
           -var="region=$REGION" \
           -var="my_ip=${CURRENT_IP}/32" \
           -auto-approve

echo "---------------------------------------------------"
echo "Deployment Complete."
echo "---------------------------------------------------"
echo "IMPORTANT: The app needs about 5 minutes to be fully up and running due to Load Balancer setup"
echo "IMPORTANT: The app can be accessed only from your IP, which is: $CURRENT_IP/32"
