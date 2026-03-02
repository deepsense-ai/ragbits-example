# Common configuration for deploy_infra.sh & destroy_infra.sh

TARGET_CLOUD="AWS" # available options: "AWS", "GCP"

# Common variables
APP_NAME="ragbits-chat"
OPENAI_API_KEY="" #insert your key here (committing it to repo is forbidden)

# GCP config
GCP_PROJECT_ID="ds-ragbits-example" # this must be the same project as the service key that was generated in get_gcp_key.ssh
GCP_REGION="europe-central2"
GCP_STATE_BUCKET="ragbits-example-deployment" # this name must be globally unique

# AWS config
AWS_REGION="eu-central-1"
AWS_ACCOUNT_ID="" # this is 12-digit account ID that you can find in your AWS console
AWS_STATE_BUCKET="ragbits-example-deployment" # this name must be globally unique

# this is needed for whitelisting the app in both deploys, so we fetch it here
CURRENT_IP=$(curl -s ifconfig.me)
if [ -z "$CURRENT_IP" ]; then
    echo "Error: Could not fetch public IP. Are you connected to the internet?"
    exit 1
fi
