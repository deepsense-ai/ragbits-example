#!/bin/bash
set -e

# Configuration loading
source "$(dirname "$0")/config.sh"

if [ ! -f "$GCP_KEY_FILE" ]; then
    echo "Error: Google Cloud Service Account key not found at $GCP_KEY_FILE"
    exit 1
fi

if [ -z "$OPENAI_API_KEY" ]; then
    echo "Error: OPENAI_API_KEY environment variable is not set."
    exit 1
fi

echo "Starting deployment for $APP_NAME..."

# GCP Authentication
echo "Authenticating with Service Account..."
gcloud auth activate-service-account --key-file="$GCP_KEY_FILE" --project="$PROJECT_ID" --quiet
gcloud config set project "$PROJECT_ID" --quiet

# Creating bucket for Terraform state file storing
echo "Checking Terraform State Bucket..."
if ! gcloud storage buckets describe "gs://$TF_STATE_BUCKET" &>/dev/null; then
    echo "Creating bucket gs://$TF_STATE_BUCKET..."
    gcloud storage buckets create "gs://$TF_STATE_BUCKET" --location="$REGION" --project="$PROJECT_ID"
    gcloud storage buckets update "gs://$TF_STATE_BUCKET" --versioning
else
    echo "Bucket gs://$TF_STATE_BUCKET already exists."
fi

echo "Initializing Infrastructure..."
cd infrastructure/terraform
tofu init -reconfigure -backend-config="bucket=$TF_STATE_BUCKET"

# Initializing Artifact Registry and Secret Manager, so that we can upload the docker
# image and OpenAI API key before we actually deploy the app
echo "Creating Artifact Registry and Secret Manager resources..."
tofu apply -target=google_artifact_registry_repository.repo \
           -target=google_secret_manager_secret.api_key \
           -var="project_id=$PROJECT_ID" \
           -var="region=$REGION" \
           -auto-approve

# Docker image & OpenAI key upload
echo "Uploading OpenAI API Key to Secret Manager..."
echo -n "$OPENAI_API_KEY" | gcloud secrets versions add openai-api-key --data-file=- --quiet

echo "Building and Pushing Docker Image..."
REPO_URL=$(tofu output -raw repository_url)
REGISTRY_HOST=$(echo "$REPO_URL" | cut -d'/' -f1)
echo "Detected Registry: $REGISTRY_HOST"
cd ../..

# Authenticate Docker specifically for this registry
gcloud auth configure-docker "$REGISTRY_HOST" --quiet

docker build -t "$REPO_URL/$APP_NAME:latest" .
docker push "$REPO_URL/$APP_NAME:latest"

# Full deployment
echo "Deploying Cloud Run Service..."
cd infrastructure/terraform

tofu apply -var="project_id=$PROJECT_ID" \
           -var="region=$REGION" \
           -auto-approve

echo "---------------------------------------------------"
echo "Deployment Complete."
echo "---------------------------------------------------"
