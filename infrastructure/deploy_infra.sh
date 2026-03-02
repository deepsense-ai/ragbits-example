#!/bin/bash
set -e
source "$(dirname "$0")/config.sh"

echo "Routing deployment for target cloud: $TARGET_CLOUD..."

if [ "$TARGET_CLOUD" = "GCP" ]; then
    bash infrastructure/gcp/deploy.sh
elif [ "$TARGET_CLOUD" = "AWS" ]; then
    bash infrastructure/aws/deploy.sh
else
    echo "Error: TARGET_CLOUD must be 'GCP' or 'AWS'."
    exit 1
fi
