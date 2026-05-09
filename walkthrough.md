# Infrastructure Project Updates Walkthrough

I have successfully updated the `TaskApp-infra` project to meet all the newly stipulated mandatory requirements. Below is a summary of the changes made across the repository.

## 1. CI/CD Pipeline Integration

To fulfill the CI/CD requirements, I implemented two robust pipeline options, favoring Jenkins as requested:

- **Jenkins Pipeline (`Jenkinsfile`)**: Created a declarative pipeline that builds Docker images for the frontend and backend, pushes them to DockerHub, and deploys the manifests to the Kubernetes cluster.
- **GitHub Actions (`.github/workflows/deploy.yml`)**: Added a secondary fallback workflow that achieves the same Build/Test/Deploy lifecycle directly from GitHub.
- **Jenkins Helm Deployment**: Added `k8s/jenkins/values.yaml` and a `k8s/jenkins/README.md` detailing the best practice of deploying the Jenkins controller directly inside the Kubernetes cluster via Helm.

## 2. Monitoring & Logging Setup (CloudWatch)

I implemented AWS CloudWatch integration to satisfy the monitoring/logging requirement:

- **CloudWatch Agent**: Created `k8s/monitoring/cloudwatch-agent.yaml` to deploy the AWS CloudWatch Agent as a DaemonSet for gathering container and node metrics.
- **Fluent Bit**: Created `k8s/monitoring/fluent-bit.yaml` to deploy Fluent Bit, which efficiently ships Kubernetes logs to AWS CloudWatch Logs.
- **IAM Permissions**: 
  - Attached the `CloudWatchAgentServerPolicy` to the Kops IAM group in `terraform/modules/iam/main.tf`.
  - Added the required `additionalPolicies` inline configuration directly to the Kops cluster specification (`kops/cluster.yaml`) so that provisioned worker nodes have native permission to push data to CloudWatch.

## 3. Documentation Standardization

The `README.md` has been completely rewritten to perfectly align with your grading/deliverable requirements. It now strictly contains:
- **Architecture overview**: Details on the EC2-based multi-AZ Kubernetes deployment.
- **Deployment steps**: Clear phases encompassing Terraform setup, Kops deployment, CI/CD execution, and App deployment.
- **Design decisions**: Rationale for using Terraform, Jenkins, Fluent Bit, etc.
- **Assumptions made**: Listed dependencies like Route53 domains, DockerHub access, and AWS credentials.
- **Limitations & Improvements**: Highlighted instance sizing limitations and future upgrade paths (like migrating to EKS).

## Verification

- The YAML manifests and Terraform syntax modifications follow standard practices.
- The `README.md` covers all mandatory sections for your deliverables.

You can now review the files, commit them to your repository, and proceed with testing your Jenkins pipeline or GitHub Actions workflow!
