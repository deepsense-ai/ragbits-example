#!/bin/bash
set -e

# Configuration loading
source "$(dirname "$0")/config.sh"

if [ ! -f "$GCP_KEY_FILE" ]; then
    echo "Error: Google Cloud Service Account key not found at $GCP_KEY_FILE"
    exit 1
fi

# GCP Authentication
echo "Authenticating with Service Account..."
gcloud auth activate-service-account --key-file="$GCP_KEY_FILE" --project="$PROJECT_ID" --quiet
gcloud config set project "$PROJECT_ID" --quiet

# Identyfing Artifact Registry
echo "Fetching Repository URL from Tofu state..."
cd infrastructure/terraform

# Initialize to ensure we can read the state
tofu init -reconfigure -backend-config="bucket=$TF_STATE_BUCKET" > /dev/null
REPO_URL=$(tofu output -raw repository_url 2>/dev/null || echo "")

# We must delete all images from Artifact Registry before destroying the repo, or Tofu will fail.
if [ -n "$REPO_URL" ]; then
    echo "Emptying Artifact Registry ($REPO_URL)..."
    
    # List all digests in the repo and delete them
    # The '|| true' ensures the script continues even if the repo is already empty
    gcloud artifacts docker images list "$REPO_URL" --include-tags --format="value(package)" 2>/dev/null | sort -u | while read -r IMAGE; do
        if [ -n "$IMAGE" ]; then
            echo "  Deleting image: $IMAGE"
            # Delete all tags associated with the image digest
            gcloud artifacts docker images delete "$IMAGE" --delete-tags --quiet || true
        fi
    done
else
    echo "Warning: Repository URL not found in state. Skipping image cleanup."
fi

# Destroys Cloud Run, IAM, Secrets, and the (now empty) Registry
echo "Running OpenTofu Destroy..."
tofu destroy -var="project_id=$PROJECT_ID" \
             -var="region=$REGION" \
             -auto-approve

# Empties & destroys terraform state bucket
cd ../.. 
echo "Destroying State Bucket gs://$TF_STATE_BUCKET..."
gcloud storage rm -r "gs://$TF_STATE_BUCKET/**" --all-versions --quiet || true
gcloud storage buckets delete "gs://$TF_STATE_BUCKET" --quiet || true

echo "---------------------------------------------------"
echo "Destruction Complete. All resources removed."
echo "---------------------------------------------------"
