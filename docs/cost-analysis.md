# Estimated AWS Cost Analysis

Operating highly-available Kubernetes on AWS with a robust 3-AZ topography incurs distinct minimal costs per AWS pricing guidelines.

| Architecture Component | Description / Spec | Quantity | Est. Monthly Cost |
|-----------------------|--------------------|----------|-------------------|
| **EC2 Linux Instances** | EC2 `t3.small` for Control Plane | 3 | ~$46.00 |
| **EC2 Linux Instances** | EC2 `t3.small` for Worker Nodes | 3 | ~$46.00 |
| **EBS Storage volumes** | Core volumes (`gp3`), Stateful volume | 6+ | ~$15.00 |
| **NAT Gateways** | Elastic IPs and NAT hourly rates distributed across 3 AZs | 3 | ~$95.00 |
| **Load Balancers** | Network Load Balancers used for API and NGINX Ingress Controller. | 2 | ~$35.00 |
| **Storage & Misc** | Route53 Zone, S3 Bucket Storage, DynamoDB lookups | N/A | ~$2.00 |

### **Total Estimated Baseline Cost:** ~$239.00 / month

**Cost Optimization Strategies**:
- To cut roughly ~60% off the EC2 prices locally, standard deployments convert the 3 Worker node InstanceGroups into AWS spot instances configured directly inside Kops mappings.
- For non-production development stages, scaling down the NAT gateways from 3 to 1 can drastically reduce network baseline spending by up to ~$65 / month.
