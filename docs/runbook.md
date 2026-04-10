# TaskApp Operational Runbook

This guide outlines standard operational procedures for maintaining the TaskApp Kubernetes cluster.

## 1. How to Deploy the Application from Scratch
1. Run `./scripts/setup_remote_state.sh`
2. `cd terraform` -> `terraform init` -> `terraform apply`
3. Export Terraform outputs internally inside the `scripts/deploy_kops.sh` and execute that script.
4. Run `kops create -f kops/cluster.yaml` followed by `kops update cluster --yes --admin`
5. Apply the main workloads by executing `./scripts/deploy_k8s_apps.sh`. 

## 2. How to Scale the Cluster (Node Count)
To proactively scale up the worker nodes if workload dramatically increases:
```bash
export KOPS_STATE_STORE="s3://taskapp-kops-state-fantoforever-com"
kops edit ig nodes-us-east-1a
# Change `maxSize` and `minSize` to 2 or 3
kops update cluster --yes
kops rolling-update cluster --yes
```

## 3. Secret Management & Rotation
Secrets are mapped using Kubernetes opaque secrets. To rotate database passwords securely:
1. Edit `k8s/core-secrets.yaml` and update base64 values, or strictly update the Vault/Secret Manager.
2. Apply changes: `kubectl apply -f k8s/core-secrets.yaml`
3. Restart pods that rely on the secret to fetch the newest variables:
   ```bash
   kubectl rollout restart deployment taskapp-backend -n taskapp
   ```

## 4. Troubleshooting Common Failures
**Issue: Pods are stuck in `Pending` state.**
- **Verification**: Run `kubectl describe pod <pod-name> -n taskapp`
- **Resolution**: Check if AWS limits have blocked EBS volume mapping, or scaling limitations prevents scheduling.

**Issue: 502 Bad Gateway observed on frontend.**
- **Verification**: Ensure the backend pod is passing readiness probes. Run `kubectl get pods -n taskapp` and `kubectl logs deployment/taskapp-backend -n taskapp`. Check if DB strings are correct causing a crash loop.
