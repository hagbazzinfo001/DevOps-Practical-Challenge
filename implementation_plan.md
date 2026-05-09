# Update Infrastructure Project to Meet New Requirements

This plan details the necessary changes to the `TaskApp-infra` project to satisfy the newly updated mandatory requirements. The existing project is built on Terraform and Kops (AWS Kubernetes), which satisfies the Cloud Deployment, Containerization, and Infrastructure as Code requirements. We will add the missing CI/CD, Monitoring, and Documentation requirements.

## User Review Required

> [!IMPORTANT]
> The requirements mention CI/CD with Jenkins as a preference. I plan to add a complete `Jenkinsfile` for the pipeline. However, deploying Jenkins itself inside the cluster requires additional resources or a separate server. For simplicity, the Jenkinsfile will assume a Jenkins server is available that has docker, kubectl, and kops installed. 
> I will also include a GitHub Actions workflow as a fallback since it is easier to test without setting up a Jenkins master. Please confirm if this approach works for you.

## Open Questions

> [!WARNING]
> 1. Do you want me to add Terraform resources/Helm charts to actually *deploy* Jenkins inside your cluster, or is simply providing the `Jenkinsfile` for a separate Jenkins instance sufficient?
> 2. For Monitoring, I will add Kubernetes manifests to deploy AWS CloudWatch Agent and Fluent Bit for logs. This requires specific IAM permissions for the worker nodes to write to CloudWatch. Is it acceptable to modify your existing Terraform IAM modules to attach the `CloudWatchAgentServerPolicy`?

## Proposed Changes

---

### CI/CD Pipeline

We will introduce CI/CD configuration files to support both Jenkins and GitHub Actions.

#### [NEW] [Jenkinsfile](file:///c:/Users/Owolabi%20Agbabiaka/Desktop/TaskApp-infra/Jenkinsfile)
A scripted/declarative Jenkins pipeline that executes:
- **Build**: Builds Docker images for `taskapp_backend` and `taskapp_frontend`.
- **Test**: Basic test execution placeholder.
- **Deploy**: Applies the Kubernetes manifests located in the `k8s/` folder to the target AWS cluster.

#### [NEW] [deploy.yml](file:///c:/Users/Owolabi%20Agbabiaka/Desktop/TaskApp-infra/.github/workflows/deploy.yml)
A GitHub Actions workflow providing a secondary CI/CD option to fulfill the requirement effortlessly on GitHub.

---

### Monitoring & Logging

We will integrate AWS CloudWatch for basic monitoring and logging.

#### [NEW] [monitoring-namespace.yaml](file:///c:/Users/Owolabi%20Agbabiaka/Desktop/TaskApp-infra/k8s/monitoring/namespace.yaml)
Namespace definition for monitoring tools.

#### [NEW] [cloudwatch-agent.yaml](file:///c:/Users/Owolabi%20Agbabiaka/Desktop/TaskApp-infra/k8s/monitoring/cloudwatch-agent.yaml)
Kubernetes manifest to deploy the AWS CloudWatch agent to collect container and node metrics.

#### [NEW] [fluent-bit.yaml](file:///c:/Users/Owolabi%20Agbabiaka/Desktop/TaskApp-infra/k8s/monitoring/fluent-bit.yaml)
Kubernetes manifest to deploy Fluent Bit as a DaemonSet to forward container logs to AWS CloudWatch Logs.

#### [MODIFY] [iam_roles](file:///c:/Users/Owolabi%20Agbabiaka/Desktop/TaskApp-infra/terraform/modules/iam)
Update the worker node IAM role in the Terraform `iam` module to include the `CloudWatchAgentServerPolicy` policy, enabling logs and metrics to be sent to CloudWatch.

---

### Documentation

We will completely rewrite the `README.md` to adhere strictly to the requested deliverables.

#### [MODIFY] [README.md](file:///c:/Users/Owolabi%20Agbabiaka/Desktop/TaskApp-infra/README.md)
The new README will include:
1. **Architecture overview**: Diagram (placeholder or description) and details of the multi-AZ Kubernetes (Kops) architecture.
2. **Deployment steps**: Clear step-by-step instructions from Terraform init to app deployment.
3. **Design decisions**: Rationale for using Terraform, Kops, Jenkins, and CloudWatch.
4. **Assumptions made**: Assumptions regarding AWS credentials, existing domain names, and local environment setup.
5. **Any limitations or improvements**: Mentions of free-tier limitations, cost considerations, and future scale-up strategies.

## Verification Plan

### Automated Tests
- I will run `terraform init` and `terraform validate` to ensure the IAM modifications are syntactically correct.
- I will lint the Kubernetes YAML manifests to ensure correctness.

### Manual Verification
- You will be able to read the updated `README.md` and verify it contains all mandatory sections.
- You can commit the code to GitHub and observe the CI/CD pipeline configuration.
