#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh" 

echo "Starting AWS Deployment..."

# bucket creation for Terraform state file storing
if ! aws s3api head-bucket --bucket "$AWS_STATE_BUCKET" 2>/dev/null; then
    echo "Creating S3 state bucket: $AWS_STATE_BUCKET..."
    aws s3api create-bucket --bucket "$AWS_STATE_BUCKET" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
    aws s3api put-bucket-versioning --bucket "$AWS_STATE_BUCKET" --versioning-configuration Status=Enabled
fi

# initializing Artifact Registry and Secret Manager, so that we can upload the docker
# image and OpenAI API key before we actually deploy the app
echo "Initializing AWS Infrastructure..."
cd infrastructure/aws/terraform
tofu init -reconfigure -backend-config="bucket=$AWS_STATE_BUCKET" -backend-config="region=$AWS_REGION"
tofu apply -target=aws_ecr_repository.repo -target=aws_secretsmanager_secret.api_key -var="region=$AWS_REGION" -var="my_ip=${CURRENT_IP}/32" -auto-approve

echo "Uploading OpenAI Key to AWS Secrets Manager..."
aws secretsmanager put-secret-value --secret-id "openai-api-key-${APP_NAME}" --secret-string "$OPENAI_API_KEY" || \
aws secretsmanager create-secret --name "openai-api-key-${APP_NAME}" --secret-string "$OPENAI_API_KEY"

REPO_URL=$(tofu output -raw repository_url)

echo "Logging into ECR ($REPO_URL)..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REPO_URL"

# build and push Docker image to ECR
cd ../../../
docker build -t "$REPO_URL:latest" .
docker push "$REPO_URL:latest"

# final apply to deploy the App Runner service and related infra
cd infrastructure/aws/terraform
tofu apply -var="region=$AWS_REGION" \
           -var="my_ip=${CURRENT_IP}/32" \
           -auto-approve

echo "---------------------------------------------------"
echo "Deployment Complete."
echo "---------------------------------------------------"
echo "IMPORTANT: The app can be accessed only from your IP, which is: $CURRENT_IP/32"