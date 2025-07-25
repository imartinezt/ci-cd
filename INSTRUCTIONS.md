# CI/CD Setup Instructions

This document provides the necessary steps to set up the CI/CD pipeline for this project.

## 1. Google Cloud Project Setup

1.  **Enable APIs:** Make sure the following APIs are enabled in your Google Cloud project:
    *   Artifact Registry API
    *   Cloud Build API
    *   Cloud Run API

2.  **Create a Service Account:**
    *   Go to **IAM & Admin > Service Accounts** and create a new service account.
    *   Grant the following roles to the service account:
        *   **Artifact Registry Writer:** To push Docker images to Artifact Registry.
        *   **Cloud Build Editor:** To run builds on Cloud Build.
        *   **Cloud Run Admin:** To deploy services to Cloud Run.
        *   **Service Account User:** To allow Cloud Build to act as the service account.
        *   **Project Viewer:** To view logs and other resources.

3.  **Create a Service Account Key:**
    *   Create a JSON key for the service account and download it.

## 2. GitHub Repository Setup

1.  **Create a `ci-cd` Environment:**
    *   In your GitHub repository, go to **Settings > Environments** and create a new environment named `ci-cd`.

2.  **Add a Secret to the Environment:**
    *   In the `ci-cd` environment, add a new secret named `SA_MLCATALOGDEV`.
    *   The value of the secret should be the content of the JSON key you downloaded from the Google Cloud console.

## 3. CI/CD Pipeline

The CI/CD pipeline is defined in the `.github/workflows/cicd.yml` file. It consists of the following jobs:

*   **lint:** Lints the code using `flake8`, `black`, and `isort`.
*   **test:** Runs the tests using `pytest`.
*   **build-and-deploy:** Builds the Docker image using Cloud Build and deploys it to Cloud Run.

The `build-and-deploy` job is triggered only when changes are pushed to the `main` branch. It uses the `SA_MLCATALOGDEV` secret to authenticate with Google Cloud.
