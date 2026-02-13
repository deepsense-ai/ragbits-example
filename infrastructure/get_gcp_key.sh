GCP_PROJECT="ds-ragbits-example"
SERVICE_ACCOUNT_NAME="ragbits-deployer"

gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
    --display-name="Ragbits Deployer" \
    --project="$GCP_PROJECT"

sleep 5 #gcloud is sometimes too fast for itself

gcloud projects add-iam-policy-binding "$GCP_PROJECT" \
    --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/owner" \
    --condition=None

sleep 5

gcloud iam service-accounts keys create infrastructure/gcp-key.json \
    --iam-account="${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT}.iam.gserviceaccount.com" \
    --project="$GCP_PROJECT"
