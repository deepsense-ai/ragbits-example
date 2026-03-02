# Ragbits Example deployment module

This module contains the infrastructure-as-code (IaC) and deployment scripts necessary to package and deploy the `ragbits-example` application to **GCP** and **AWS**. The deployment utilizes **OpenTofu** for infrastructure provisioning and **Docker** for containerization.

## Architecture Overview

The deployment provisions the following resources:

### Google Cloud Platform (GCP)
* **Google Cloud Storage (GCS)**: stores Terraform state files.
* **Google Secret Manager**: stores the `OPENAI_API_KEY` and injects it into the application.
* **Google Artifact Registry**: hosts the built Docker container images.
* **Google Cloud Run (v2)**: runs the application with ingress restricted to internal traffic and the Load Balancer.
* **Cloud Armor & Global Load Balancer**: provides a public HTTP endpoint protected by a WAF that whitelists only your current IP address.

### Amazon Web Services (AWS)
* **Amazon S3**: stores Terraform state files
* **AWS Secrets Manager**: stores the `OPENAI_API_KEY`
* **Amazon ECR**: hosts the built Docker container images
* **AWS App Runner**: runs the application
* **AWS WAF**: attaches a Web Access Control List directly to the service to whitelist only your current IP address

## How to deploy step by step

Before deploying, ensure you have the following installed and configured:

1.  **Google Cloud CLI (`gcloud`)**
2.  **AWS CLI (`aws`)**
3.  **OpenTofu (`tofu`)**
4.  **Docker (`docker`)**
5.  **OpenAI API Key**: required for the application to function.

## Authorization

Both cloud providers are configured to use your local **User Identity**, so you need to be authorized and all of the services mentioned here need to be activated in the project (in GCP case). 

### GCP Authorization
To authorize yourself for GCP run:

```bash
gcloud auth application-default login --no-launch-browser # follow the instructions from the CLI
```
**IMPORTANT**: if there are any errors during deploy for GCP, there are probably due to service APIs not being enabled for your project, just follow the instructions in the terminal in that case  

### AWS Authorization
To authorize yourself for AWS run:

```bash
aws configure # follow the instructions from the CLI
```

### Configuration & running the deployment
1. Update `infrastructure/config.sh` according to your needs
2. Run `infrastructure/deploy_infra.sh` - the app should be available via the link outputted by the script (GCP version takes few minutes to boot, AWS deploy should be ready to connect when the script finishes)
3. After you are done remember to run `infrastructure/destroy_infra.sh`
