# 🚀🔐 DevSecOps CI/CD Automation for a Financial Platform

A production-minded DevSecOps reference implementation showcasing infrastructure-as-code, secure CI/CD, and Kubernetes deployment patterns tailored for financial-grade workloads.

Important: The initial notes, rationale, and design decisions for this project are documented in the companion notes repository: 👉 [DevSecOps—Notes](https://github.com/mousrij/DevSecOps--Notes.git).

### ✨ Highlights
- **🏗️ Infrastructure as Code**: Terraform for AWS EC2 and Amazon EKS (modularized).
- **☸️ Kubernetes**: Deployment and Service manifests for a sample microservice.
- **🤖 Pipelines**: Jenkins scripted pipelines for CD and a deletion workflow.
- **🛡️ Security by Default**: Immutable images, least-privilege IAM (recommended), and supply chain hooks.

## 📁 Repository Structure
```text
DevSecOps-CI-CD-Automation-For-a-Financial-Platform/
  k8s/
    deployment.yaml
    service.yaml
  pipeline_script/
    CD_pipeline.groovy
    jenkinsFile
    pipeline_deletion.groovy
  terrafom_code/
    ec2_server/
      entry-script.sh
      main.tf
      terraform.tfstate
      terraform.tfstate.backup
      terraform.tfvars
      variables.tf
    Eks_Cluster/
      eks.tf
      provider.tf
      terraform.tfstate
      terraform.tfstate.backup
      vpc.tf
    modules/
      server/
        main.tf
        outputs.tf
        variables.tf
      subnet/
        main.tf
        outputs.tf
        variables.tf
```

Note: `terraform.tfstate` files are present for illustration. In real projects, use a remote backend (e.g., S3 + DynamoDB locks) and never commit local state to VCS. ⚠️

## 🧰 Prerequisites
- AWS account with programmatic access (Access Key ID and Secret Access Key)
- Terraform >= 1.4
- kubectl >= 1.27
- AWS CLI >= 2.0
- Jenkins (controller/agent) with Docker or Kubernetes build capability
- Git and a container registry (e.g., ECR, Docker Hub, GHCR)

## 🚀 Quick Start
1) Clone the repo
```bash
git clone https://github.com/your-org/DevSecOps-CI-CD-Automation-For-a-Financial-Platform.git
cd DevSecOps-CI-CD-Automation-For-a-Financial-Platform
```

2) Export AWS credentials (or configure via `aws configure`)
```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1
```

3) Initialize Terraform
```bash
cd terrafom_code/Eks_Cluster
terraform init
```

4) Review and set variables
```bash
terraform plan -out=tfplan
```

5) Apply infrastructure
```bash
terraform apply tfplan
```

6) Configure kubeconfig for the new EKS cluster
```bash
aws eks update-kubeconfig --name <your-eks-cluster-name> --region ${AWS_DEFAULT_REGION}
kubectl get nodes
```

7) Deploy the application manifests
```bash
cd ../../k8s
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get pods,svc
```

## 🏗️ Terraform Overview
The `terrafom_code` directory manages both EC2 and EKS resources.

- `ec2_server/`: Example EC2 provisioning using variables and a startup script (`entry-script.sh`).
- `Eks_Cluster/`: Core EKS cluster provisioning along with VPC networking (`vpc.tf`).
- `modules/`: Reusable Terraform modules for `server` and `subnet` to standardize resource creation.

Recommendations:
- Configure a remote backend (S3 + DynamoDB) and remove local `terraform.tfstate` from VCS.
- Use separate workspaces or directories for environments (dev, staging, prod).
- Pin provider versions and module sources for reproducibility.

## ☸️ Kubernetes Manifests
- `k8s/deployment.yaml`: Defines the application Deployment. Ensure the image reference is updated to your registry.
- `k8s/service.yaml`: Exposes the application internally or externally depending on the Service type.

Typical rollout commands:
```bash
kubectl apply -f k8s/
kubectl rollout status deployment/<deployment-name>
kubectl describe service <service-name>
```

## 🤖 Jenkins Pipelines
Location: `pipeline_script/`

- `jenkinsFile`: Entry pipeline definition integrating build, scan, test, and deploy stages.
- `CD_pipeline.groovy`: Scripted CD pipeline to deploy to Kubernetes after passing quality gates.
- `pipeline_deletion.groovy`: Safe teardown pipeline for ephemeral environments.

Suggested stages (customize as needed):
- ✅ Build and Unit Test
- 🧱 Container Build and Tag
- 🧪 SAST/Dependency Scan (e.g., Trivy, Grype, Snyk)
- ✍️ Image Signing/Attestation (e.g., Cosign)
- 🚢 Deploy to Non-Prod EKS
- 🔍 Smoke Tests and Health Checks
- 🧑‍⚖️ Manual Approval (for prod)
- 🚀 Deploy to Prod EKS

## 🔒 Security Considerations
- Prefer minimal base images and run as non-root in `deployment.yaml`.
- Use image scanning in CI and fail on critical findings.
- Configure IAM Roles for Service Accounts (IRSA) for fine-grained pod access to AWS.
- Enable network policies and restrict egress where possible.
- Use admission control (OPA/Gatekeeper or Kyverno) to enforce policies.
- Store secrets in AWS Secrets Manager or SSM Parameter Store and mount via CSI driver.

## 🧹 Clean Up
To remove Kubernetes resources:
```bash
kubectl delete -f k8s/
```

To tear down infrastructure:
```bash
cd terrafom_code/Eks_Cluster
terraform destroy
```

## 🛠️ Troubleshooting
- EKS kubeconfig issues: verify cluster name and region, and ensure your IAM user/role has the required permissions.
- Nodes not ready: check VPC/subnet configurations and worker node IAM roles; review `kubectl describe nodes`.
- Service not reachable: confirm Service type, targetPorts, and security groups.
- Terraform state conflicts: use a remote backend with state locking.

## 📝 Notes and Design Rationale
For background notes, decisions, and first principles applied to this project, see: [DevSecOps—Notes](https://github.com/mousrij/DevSecOps--Notes.git).

## 🤝 Contributing
Issues and PRs are welcome. Please follow conventional commits and include clear descriptions and test coverage where applicable. 🙏

## 📄 License
Specify your license here (e.g., Apache-2.0, MIT). If omitted, the repository is considered All Rights Reserved by default.