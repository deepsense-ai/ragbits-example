#!/bin/bash
set -e

# configuration loading
source "$(dirname "$0")/../config.sh"

# GCP Authentication
gcloud config set project "$PROJECT_ID" --quiet

# identyfing Artifact Registry
echo "Fetching Repository URL from Tofu state..."
cd infrastructure/gcp/terraform

# initialize to ensure we can read the state
tofu init -reconfigure -backend-config="bucket=$TF_STATE_BUCKET" > /dev/null
REPO_URL=$(tofu output -raw repository_url 2>/dev/null || echo "")

# all images must be deleted from Artifact Registry before destroying the repo, or Tofu will fail.
if [ -n "$REPO_URL" ]; then
    echo "Emptying Artifact Registry ($REPO_URL)..."
    
    # list all digests in the repo and delete them
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

# destroys Cloud Run, IAM, Secrets, Registry
echo "Running OpenTofu Destroy..."
tofu destroy -var="project_id=$PROJECT_ID" \
             -var="region=$REGION" \
             -var="my_ip=${CURRENT_IP}/32" \
             -auto-approve

# empties & destroys terraform state bucket
echo "Destroying State Bucket gs://$TF_STATE_BUCKET..."
gcloud storage rm -r "gs://$TF_STATE_BUCKET/**" --all-versions --quiet || true
gcloud storage buckets delete "gs://$TF_STATE_BUCKET" --quiet || true

echo "---------------------------------------------------"
echo "Destruction Complete. All resources removed."
echo "---------------------------------------------------"
