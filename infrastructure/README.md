# Ragbits Example deployment module

This module contains the infrastructure-as-code (IaC) and deployment scripts necessary to package and deploy the `ragbits-example` application to GCP. The deployment utilizes **OpenTofu** for infrastructure provisioning and **Docker** for containerization.

## Architecture overview

The deployment provisions the following GCP resources:
* **Google Cloud Storage (GCS)**: stores Terraform state file
* **Google Secret Manager**: stores`OPENAI_API_KEY` and injects it into the application at runtime
* **Google Artifact Registry**: hosts the built Docker container images
* **Google Cloud Run (v2)**: runs the example application
* **Service Accounts & IAM**: dedicated identity provider (`ragbits-chat-sa`) for the Cloud Run service with permissions to access the Secret Manager

## Prerequisites

Before deploying, ensure you have the following installed and configured on your local machine:

1.  **Google Cloud CLI (`gcloud`)** - authenticated (`gcloud auth login`) in the project you want to deploy into, for which a service account will be created in order for Terraform to run
2.  **OpenTofu (`tofu`)**
3.  **Docker (`docker`)**

## Access keys:
1.  **GCP Service Account Key**: A JSON key file for a GCP service account with necessary permissions (Storage Admin, Cloud Run Admin, Secret Manager Admin, Artifact Registry Admin, IAM Admin). Check `get_gcp_key.ssh` to generate this JSON file.
2.  **OpenAI API Key**: Required for the Ragbits application to function, get it from [here](https://platform.openai.com/api-keys) or your IT departement.

## Configuration & running the deployment
- Before running the deployment itself first you need to get a service key for GCP with which deployment is authorized - fill in the fields in `get_gcp_key.ssh` and run it in order to generate the key.
    
    ```bash
    GCP_PROJECT="ds-ragbits-example"
    SERVICE_ACCOUNT_NAME="ragbits-deployer"
- When you have both the GCP key in JSON file and `OPENAI_API_KEY` you can run the deployment - you must update the configuration variables in both the bash scripts before running `deploy_infra.sh` & `destroy_infra.sh`:
    Edit the top configuration section of these scripts to match your environment. The configurations need to be matching between deploy and destroy in order to work correctly.

    **IMPORTANT**: Always run `destroy_infra.sh` after `deploy_infra.sh`, when the deployed app is not needed anymore to not generate costs

    ```bash
    PROJECT_ID="ds-ragbits-example" # your own project ID
    REGION="europe-central2" # region closest to you
    APP_NAME="ragbits-chat" # can stay default
    TF_STATE_BUCKET="ragbits-example-deployment" # can stay default
    GCP_KEY_FILE="infrastructure/gcp-key.json" # this is the hardcoded location of this file, should stay default
    OPENAI_API_KEY="your-openai-api-key" # your own OpenAI API key
- After you run `deploy_infra.sh` and it deploys successfully, you need to create a proxy tunnel, since the app is nonpublic and authorization is needed for connection. Do it by executing:

    ```bash 
    gcloud run services proxy ragbits-chat --project ds-ragbits-example --region europe-central2 --port=8000
- Finally you are able to connect to the app at `127.0.0.1:8000`
- **Always remember to `destroy_infra.sh` after you are finished**
