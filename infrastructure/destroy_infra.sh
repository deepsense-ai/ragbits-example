#!/bin/bash
set -e
source "$(dirname "$0")/config.sh"

echo "Routing destruction for target cloud: $TARGET_CLOUD..."

if [ "$TARGET_CLOUD" = "GCP" ]; then
    bash infrastructure/gcp/destroy.sh
elif [ "$TARGET_CLOUD" = "AWS" ]; then
    bash infrastructure/aws/destroy.sh
else
    echo "Error: TARGET_CLOUD must be 'GCP' or 'AWS'."
    exit 1
fi
