# Common configuration for deploy_infra.sh & destroy_infra.sh
PROJECT_ID="ds-ragbits-example" # this must be the same project as the service key that was generated in get_gcp_key.ssh
REGION="europe-central2"
APP_NAME="ragbits-chat"
TF_STATE_BUCKET="ragbits-example-deployment" # this name must be globally unique
GCP_KEY_FILE="infrastructure/gcp-key.json" # this is a service key, run get_gcp_key.sh in order to get it
OPENAI_API_KEY="" #insert your key here (committing it to repo is forbidden)