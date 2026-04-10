#!/bin/bash
set -e

echo "WARNING: This will completely destroy your entire Kops and Terraform AWS environment!"
echo "Press Ctrl+C immediately to abort, or press Enter to continue..."
read -r

echo " 1. Destroying Kubernetes Cluster (Kops)..."
export KOPS_STATE_STORE="s3://taskapp-kops-state-fantoforever-com"
kops delete cluster --name taskapp.fantoforever.com --yes

echo " 2. Destroying Core AWS Infrastructure (Terraform)..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
cd "$SCRIPT_DIR/../terraform"
terraform destroy -auto-approve

echo " Environment completely destroyed safely!"
