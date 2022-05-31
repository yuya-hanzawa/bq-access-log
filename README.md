# bq-access-log

## Description
I aggregated the access logs of my own homepage into BigQuery.

</br>

## Data Lake Table
<img width="1142" alt="スクリーンショット 2021-12-06 21 04 55" src="https://user-images.githubusercontent.com/58725085/144843486-100b5b25-4f63-4d6c-9e25-c4fc0df8dac8.png">

## Improvements
1. Manage permissions with terraform.
2. Learn more terraform and write nicely.

</br>

## Usage
### 1. Clone Codes
```
$ git clone https://github.com/zawa1120/bq-access-log.git
```

### 2. Install Google Cloud SDK & Terraform
```
$ brew install google-cloud-sdk --cask
$ brew install terraform
```

### 3. Setting up Google Cloud SDK
```
$ gcloud init
```

### 4. Create a service account and grant access rights
```
$ cd terraform
$ gcloud iam service-accounts create SERVICE_ACCOUNT_NAME --display-name DISPLAY_NAME
$ gcloud projects add-iam-policy-binding PROJECT_ID --member serviceAccount:SERVICE_ACCOUNT_NAME@PROJECT_ID.iam.gserviceaccount.com --role roles/editor
$ gcloud iam service-accounts keys create gcp/account.json --iam-account SERVICE_ACCOUNT_NAME@PROJECT_ID.iam.gserviceaccount.com
$ export GOOGLE_CLOUD_KEYFILE_JSON=gcp/account.json
```
### 5. Deploy Terraform
```
$ terraform init
$ terraform plan
$ terraform apply
```

### 6. Deploy Cloud Functions
```
$ cd functions
$ bash deploy.sh
```

</br>

## Requirements
- macOS Big Sur 11.4 Apple M1
  - Homebrew 3.3.6

- Google Cloud SDK 365.0.1
  - bq 2.0.71
  - core 2021.11.19
  - gsutil 5.5

- Tools
  - Terraform v1.0.11
