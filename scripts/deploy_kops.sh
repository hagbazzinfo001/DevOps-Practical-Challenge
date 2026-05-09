#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

echo "Using your default AWS profile (from ~/.aws/credentials) to authenticate..."
export AWS_REGION="us-east-1"

DOMAIN_NAME="fantoforever.com" 
CLUSTER_NAME="taskapp.${DOMAIN_NAME}"
export KOPS_STATE_STORE="s3://taskapp-kops-state-${DOMAIN_NAME//./-}"

echo "Creating Kops state store bucket if it doesn't exist..."
aws s3api create-bucket --bucket taskapp-kops-state-${DOMAIN_NAME//./-} --region us-east-1 || true
aws s3api put-bucket-versioning --bucket taskapp-kops-state-${DOMAIN_NAME//./-} --versioning-configuration Status=Enabled || true

echo "Applying Kops configuration from kops/cluster.yaml..."
kops replace -f "$SCRIPT_DIR/../kops/cluster.yaml" --force

echo "Building the cluster in AWS..."
kops update cluster --name ${CLUSTER_NAME} --yes --admin

echo "Waiting for the cluster to become ready..."
kops validate cluster --wait 10m
