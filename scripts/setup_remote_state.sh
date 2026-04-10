#!/bin/bash
set -e

# Update these per your environment
AWS_REGION="us-east-1"
# Ensure the bucket name is globally unique
BUCKET_NAME="taskapp-capstone-tf-state-unique123"
DYNAMODB_TABLE="taskapp-tf-state-lock"

echo "Creating S3 bucket for Terraform remote state..."
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $AWS_REGION

echo "Enabling Versioning on S3 Bucket..."
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

echo "Creating DynamoDB table for State Locking..."
aws dynamodb create-table \
    --table-name $DYNAMODB_TABLE \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $AWS_REGION

echo "Backend infrastructure created successfully! You can now run `terraform init`."
