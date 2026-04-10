# TaskApp Cloud-Native Architecture

This document explicitly outlines the architectural configurations, high-availability guarantees, and defensive networking layers orchestrated to run the TaskApp environment securely on AWS.

## 🗺️ System Architecture Diagram

```mermaid
graph TD
    classDef public fill:#e2f0d9,stroke:#548235,stroke-width:2px,color:#000;
    classDef private fill:#fff2cc,stroke:#d6b656,stroke-width:2px,color:#000;
    classDef aws fill:#dae8fc,stroke:#6c8ebf,stroke-width:2px,color:#000;

    User(("End User")) -->|HTTPS (Port 443)| Route53

    subgraph "AWS Cloud Infrastructure"
        Route53["DNS (Route 53)"]:::aws
        S3["Kops State Store (S3)"]:::aws

        subgraph "Virtual Private Cloud (VPC)"
            Route53 -.->|Alias| ELB["AWS Load Balancer<br>(Public, Ingress)"]:::public
            IGW["Internet Gateway"]:::public

            subgraph "Public 'Utility' Subnets"
                NAT_A["NAT Gateway (AZ: 1a)"]:::public
                NAT_B["NAT Gateway (AZ: 1b)"]:::public
                NAT_C["NAT Gateway (AZ: 1c)"]:::public
                ELB -.-> NAT_A
            end

            subgraph "Deep Private Subnets (Workloads)"
                subgraph "us-east-1a"
                    K8_M1["Master Node<br>t3.small"]:::private
                    K8_W1["Worker Node<br>t3.small"]:::private
                end

                subgraph "us-east-1b"
                    K8_M2["Master Node<br>t3.small"]:::private
                    K8_W2["Worker Node<br>t3.small"]:::private
                end

                subgraph "us-east-1c"
                    K8_M3["Master Node<br>t3.small"]:::private
                    K8_W3["Worker Node<br>t3.small"]:::private
                end
            end
        end
    end

    ELB -->|Nginx Ingress Traffic| K8_W1
    ELB -->|Nginx Ingress Traffic| K8_W2
    ELB -->|Nginx Ingress Traffic| K8_W3

    K8_W1 -.->|Outbound| NAT_A
    K8_W2 -.->|Outbound| NAT_B
    K8_W3 -.->|Outbound| NAT_C

    NAT_A -.-> IGW
    NAT_B -.-> IGW
    NAT_C -.-> IGW
```

---

## 🔢 1. CIDR Allocation Rationale
The network relies on a vast `/16` foundational VPC, mapped methodically into identical `/20` subnets.
- **Base VPC (`10.0.0.0/16`)**: Yields 65,536 absolute IP addresses guaranteeing zero risk of internal IP exhaustion as Pods horizontally scale.
- **Strict Network Partitioning**: 
  - **Public (Utility) Subnets** are mapped to `10.0.0.0/20`, `10.0.16.0/20`, and `10.0.32.0/20`. Each holds identically 4,096 IPs. These primarily house the stateless AWS NAT Gateways and the NGINX Ingress Load Balancers bridging to the open internet.
  - **Private Subnets** are mapped to `10.0.48.0/20`, `10.0.64.0/20`, and `10.0.80.0/20`. This isolates the core Kubernetes nodes completely away from public ingress routing. 

## ⚖️ 2. High Availability Strategy Explanation
The fundamental objective of this deployment is guaranteeing that the loss of an entire physical datacenter (AWS Availability Zone) results in zero total downtime.

1. **Multi-AZ Geographic Distribution:** The infrastructure strictly mandates deployments evenly spread across 3 discrete physical AWS zones (`us-east-1a`, `us-east-1b`, `us-east-1c`).
2. **Kubernetes Control Plane (Master Quorum):** Built as a 3-node HA control plane meaning if `us-east-1a` suffers power-failure, `etcd` retains read-write consensus via the remaining 2 masters securely.
3. **Container Zero-Downtime Reliability ($maxUnavailable=0$):** Kubernetes deployments scale replicas across the nodes utilizing `RollingUpdate` strategies. When containers refresh, K8s intentionally refuses to kill old containers until dynamic HTTP liveness probes confirm new deployments boot reliably (`CrashLoopBackOff` resistance).

## 🛡️ 3. Security Model Description 
To prevent hostile infiltration or data exfiltration, standard "Defense-in-Depth" multi-tier segregation applies:
1. **Network Layer Isolation (No SSH surface):** All actual Kubernetes cluster EC2 Instances reside in strictly **Private Subnets**. They possess zero Public IP addresses. Their only outbound capacity routes purely backward through highly-regulated AWS NAT Gateways.
2. **Database Hardening:** The Stateful PostgreSQL database operates exclusively native within the inner K8s cluster IP mesh. It possesses no NodePort exposure whatsoever, making it physically impossible to execute SQL injections straight from the internet.
3. **Data-in-Transit Encryption:** Let's Encrypt TLS Certificates govern standard encryption dynamically. Traffic terminates safely on the NGINX Ingress controller, isolating malicious packet transmission natively prior to navigating inside the pod subnets.
4. **GitOps Zero-Secret Exfiltration:** Raw `.env` variable maps and credential payloads, exactly like `k8s/core-secrets.yaml`, are hardcoded explicitly into `.gitignore` files to guarantee plain-text variables explicitly stay outside repository control.
