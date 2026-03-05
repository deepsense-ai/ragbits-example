# Common configuration for deploy_infra.sh & destroy_infra.sh

TARGET_CLOUD="GCP" # available options: "AWS", "GCP"

# Common variables
APP_NAME="ragbits-chat"
OPENAI_API_KEY="" #insert your key here (committing it to repo is forbidden)

# GCP config
GCP_PROJECT_ID="ds-ragbits-example" # this must be a project where you have permissions to create resources
GCP_REGION="europe-central2"
GCP_STATE_BUCKET="ragbits-example-deployment" # this name must be globally unique

# AWS config
AWS_REGION="eu-central-1" # this region must be the same as the one in your AWS CLI configuration
AWS_ACCOUNT_ID="" # this is 12-digit account ID that you can find in your AWS console
AWS_STATE_BUCKET="ragbits-example-deployment" # this name must be globally unique

# this is needed for whitelisting the app in both deploys, so we fetch it here
# the -4 flag ensures we get an ipv4 address, which is what we need for whitelisting in GCP and AWS security groups
# ipv6 addresses won't work for whitelisting in this context, so beware of that
CURRENT_IP=$(curl -4 -s ifconfig.me) 
if [ -z "$CURRENT_IP" ]; then
    echo "Error: Could not fetch public IP. Are you connected to the internet?"
    exit 1
fi
