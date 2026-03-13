#!/bin/bash
set -e
source "$(dirname "$0")/../config.sh"

echo "Starting AWS Destruction..."

cd infrastructure/aws/terraform
tofu init -reconfigure -backend-config="bucket=$AWS_STATE_BUCKET" -backend-config="region=$AWS_REGION" > /dev/null

REPO_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}-repo"

echo "Emptying ECR Repository..."

# AWS requires repos to be empty before deletion
aws ecr list-images --repository-name "${APP_NAME}-repo" --region "$AWS_REGION" --query 'imageIds[*]' --output json | \
  jq -r 'if type == "array" and length > 0 then . else empty end' | \
  xargs -I {} aws ecr batch-delete-image --repository-name "${APP_NAME}-repo" --region "$AWS_REGION" --image-ids "{}" > /dev/null 2>&1 || true

echo "Destroying AWS infrastructure"
tofu destroy -var="region=$AWS_REGION" -var="my_ip=${CURRENT_IP}/32" -auto-approve

echo "Destroying S3 state bucket"
VERSIONS=$(aws s3api list-object-versions --bucket "$AWS_STATE_BUCKET" --query="Versions[].{Key:Key,VersionId:VersionId}" --output=json)
if [ "$VERSIONS" != "null" ]; then
    aws s3api delete-objects --bucket "$AWS_STATE_BUCKET" --delete "{\"Objects\":$VERSIONS}" > /dev/null
fi

MARKERS=$(aws s3api list-object-versions --bucket "$AWS_STATE_BUCKET" --query="DeleteMarkers[].{Key:Key,VersionId:VersionId}" --output=json)
if [ "$MARKERS" != "null" ]; then
    aws s3api delete-objects --bucket "$AWS_STATE_BUCKET" --delete "{\"Objects\":$MARKERS}" > /dev/null
fi

aws s3api delete-bucket --bucket "$AWS_STATE_BUCKET" --region "$AWS_REGION"
echo "---------------------------------------------------"
echo "Destruction Complete. All resources removed."
echo "---------------------------------------------------"
