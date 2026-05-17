# Terraform AWS Infrastructure

Modular Terraform project for AWS provisioning, designed to run from **AWS CloudShell** with remote state on S3 and DynamoDB locking.

---

## 📁 Structure

```
Terraform/
├── Initial Setup/
│   ├── bootstrap Config/       # Creates S3 state bucket + DynamoDB lock table (run once)
│   └── Cloudshell Config/      # Session persistence scripts for AWS CloudShell
│
└── Infra/
    ├── environments/
    │   ├── dev/dev.tfvars
    │   └── prod/prod.tfvars
    ├── modules/
    │   ├── vpc/
    │   ├── ec2/
    │   ├── s3/
    │   └── lambda/
    ├── backend.tf
    ├── main.tf
    ├── provider.tf
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars
```

---

## 🚀 First-Time Setup

### 1. Bootstrap — create remote backend (run once)
```bash
cd "Initial Setup/bootstrap Config"
terraform init
terraform apply
```

### 2. CloudShell session scripts
```bash
cp "Initial Setup/Cloudshell Config/tf-start.sh" ~/
cp "Initial Setup/Cloudshell Config/tf-save.sh" ~/
chmod +x ~/tf-start.sh ~/tf-save.sh
```

### 3. Initialize and deploy
```bash
cd Infra/
export TF_DATA_DIR=/tmp/.terraform
terraform init
terraform apply -var-file="environments/dev/dev.tfvars"
```

---

## 🔄 Daily CloudShell Workflow

```bash
source ~/tf-start.sh        # Start — restores plugins from S3
export TF_DATA_DIR=/tmp/.terraform

# ... do your work ...

source ~/tf-save.sh         # End — saves plugins back to S3
```

---

## ☁️ Remote Backend

| | |
|---|---|
| S3 Bucket | `shanthosh-terraform-state-2026` |
| DynamoDB Table | `shanthosh-terraform-locks` |
| Region | `ap-south-1` |

---

> ⚠️ Always run `terraform destroy` after practice sessions to avoid EC2 charges.
