# Jenkins CI/CD Deployment Guide

This guide provides explicit, step-by-step instructions on how to deploy Jenkins directly into your Kubernetes cluster, retrieve your initial admin password, and configure it to run your `Jenkinsfile` pipeline.

## Prerequisites
- Helm v3 installed locally (`brew install helm` or `choco install kubernetes-helm`)
- `kubectl` configured and actively communicating with your newly provisioned Kops cluster.

---

## Step 1: Install Jenkins via Helm

1. **Add the Jenkins Helm repository:**
   ```bash
   helm repo add jenkins https://charts.jenkins.io
   helm repo update
   ```

2. **Create a dedicated namespace for Jenkins:**
   ```bash
   kubectl create namespace jenkins
   ```

3. **Deploy Jenkins using the provided `values.yaml` configuration:**
   This configuration automatically pre-installs the necessary plugins (Docker, Kubernetes, Git).
   ```bash
   helm install my-jenkins jenkins/jenkins -n jenkins -f values.yaml
   ```

---

## Step 2: Access the Jenkins UI

1. **Retrieve the Jenkins Admin Password:**
   By default, the `values.yaml` hardcodes the password to `admin_password`. However, if you removed it for security, you can extract the generated password from Kubernetes secrets:
   ```bash
   kubectl exec --namespace jenkins -it svc/my-jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
   ```

2. **Port-Forward to Access the Dashboard:**
   To access Jenkins locally without exposing it to the public internet, use Kubernetes port-forwarding:
   ```bash
   kubectl --namespace jenkins port-forward svc/my-jenkins 8080:8080
   ```
3. **Log In:**
   Open your browser and navigate to `http://localhost:8080`. Log in using:
   - **Username**: `admin`
   - **Password**: `admin_password` (or the extracted secret).

---

## Step 3: Configure Credentials in Jenkins

For the `Jenkinsfile` to successfully push Docker images and deploy to Kubernetes, it needs your credentials.

### A. Add DockerHub Credentials
1. In the Jenkins dashboard, go to **Manage Jenkins** -> **Credentials**.
2. Click on **(global)** under the Domains list, then click **Add Credentials** (top right).
3. Set the following fields:
   - **Kind**: Username with password
   - **Scope**: Global
   - **Username**: `<Your-DockerHub-Username>`
   - **Password**: `<Your-DockerHub-Password-or-Token>`
   - **ID**: `dockerhub-credentials` *(This MUST match the ID in your Jenkinsfile)*
   - **Description**: Docker Hub access
4. Click **Create**.

### B. Add Kubeconfig Credentials
The Jenkins pipeline needs access to your cluster to run `kubectl apply`.
1. From your local terminal, export your Kops kubeconfig to a file:
   ```bash
   kops export kubeconfig --admin --name taskapp.k8s.local --state s3://taskapp-kops-state-local --kubeconfig ./kubeconfig-temp
   ```
2. In Jenkins, go to **Add Credentials** again.
3. Set the following fields:
   - **Kind**: Secret file
   - **Scope**: Global
   - **File**: Upload the `./kubeconfig-temp` file you just generated.
   - **ID**: `kops-kubeconfig` *(This MUST match the ID in your Jenkinsfile)*
   - **Description**: Kops Kubernetes Config
4. Click **Create**, then safely delete the `./kubeconfig-temp` file from your local machine.

---

## Step 4: Create the CI/CD Pipeline Job

Now that Jenkins has your credentials, you need to tell it to read the `Jenkinsfile` from your repository.

1. Go to the Jenkins Dashboard and click **New Item**.
2. Enter a name for your pipeline (e.g., `TaskApp-Pipeline`).
3. Select **Multibranch Pipeline** and click **OK**.
4. Scroll down to the **Branch Sources** section:
   - Click **Add source** -> **Git**.
   - Enter your project's Git Repository URL (e.g., `https://github.com/your-username/TaskApp-infra.git`).
   - If your repository is private, add your GitHub credentials here as well.
5. Scroll down to the **Build Configuration** section:
   - Ensure the Mode is set to "by Jenkinsfile".
   - Script Path should be `Jenkinsfile`.
6. Click **Save**.

Jenkins will immediately scan your repository, detect the `Jenkinsfile` on your `main` branch, and automatically start the Build, Test, and Deploy process!
