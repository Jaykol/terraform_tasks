# Terraform AWS Infrastructure — EC2 Provisioning

Terraform configuration to provision a basic AWS infrastructure stack from scratch. Deploys a Ubuntu 22.04 EC2 instance with a dynamically resolved AMI, configures a security group with HTTP and SSH access rules, and manages an SSH key pair — all as code.

Built as part of a hands-on DevOps learning path covering Infrastructure as Code, alongside Docker, Kubernetes, and CI/CD pipeline work.

---

## What this provisions

| Resource | Details |
|---|---|
| EC2 Instance | t3.micro, Ubuntu 22.04 LTS (dynamic AMI lookup) |
| Security Group | HTTP open on port 80, SSH restricted to specified IP |
| SSH Key Pair | ed25519 key registered with AWS |
| Instance State | Managed via `aws_ec2_instance_state` |

---

## Architecture

```
AWS (us-east-1)
└── EC2 Instance (t3.micro)
    ├── AMI: Ubuntu 22.04 LTS (latest, dynamic lookup)
    ├── Key Pair: terra-key (ed25519)
    └── Security Group: terra-sg
        ├── Inbound: TCP 80 from 0.0.0.0/0 (HTTP)
        ├── Inbound: TCP 22 from <your-ip>/32 (SSH)
        └── Outbound: All traffic allowed
```

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.11
- AWS account with IAM credentials configured
- AWS CLI configured (`aws configure`) or environment variables set:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

---

## Usage

### 1. Clone the repository

```bash
git clone https://github.com/Jaykol/terraform-aws-ec2.git
cd terraform-aws-ec2
```

### 2. Set your variables

Copy the example file and fill in your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
ssh_ip     = "your.ip.address.here"
public_key = "ssh-ed25519 AAAA... your-public-key"
```

To find your current public IP:
```bash
curl -s ifconfig.me
```

To get your SSH public key:
```bash
cat ~/.ssh/id_ed25519.pub
```

### 3. Initialise Terraform

```bash
terraform init
```

### 4. Preview the plan

```bash
terraform plan
```

### 5. Apply

```bash
terraform apply
```

Type `yes` when prompted. Terraform will output the AMI ID on completion.

### 6. Destroy when done

```bash
terraform destroy
```

---

## File structure

```
.
├── provider.tf                # AWS provider — region pulled from variable
├── instance.tf                # EC2 instance, AMI data source, output
├── keypair.tf                 # SSH key pair — public key from variable
├── securitygroup.tf           # Security group — SSH IP from variable
├── vars.tf                    # All input variables with descriptions
├── terraform.tfvars.example   # Template for local values (safe to commit)
├── .terraform.lock.hcl        # Provider version lock file
├── .gitignore                 # Excludes state files, keys, and tfvars
└── README.md
```

---

## Key concepts demonstrated

**Dynamic AMI lookup** — Uses a `data` source to always resolve the latest Ubuntu 22.04 LTS AMI at plan time, rather than hardcoding an AMI ID that goes stale.

```hcl
data "aws_ami" "amiID" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}
```

**Input variables** — Region, availability zone, AMI map, SSH IP, and public key are all declared in `vars.tf` and passed at runtime via `terraform.tfvars`. No sensitive values are hardcoded in source.

```hcl
variable "ssh_ip" {
  description = "Your IP address for SSH access"
  type        = string
}
```

**Multi-region AMI map** — A map variable holds AMI IDs per region, making the config portable across `us-east-1` and `us-west-2` without code changes.

```hcl
variable "amiID" {
  default = {
    "us-east-1" = "ami-068c0051b15cdb816"
    "us-west-2" = "ami-0ebf411a80b6b22cb"
  }
}
```

**Least-privilege security group** — SSH access locked to a single IP via `/32` CIDR. HTTP open on port 80 only.

**Output values** — AMI ID is surfaced as a Terraform output for use in downstream configurations or pipelines.

---

## Progression

This repo reflects two iterations of the same infrastructure:

**Iteration 1 — Initial provisioning**
- EC2 instance, security group, and SSH key pair provisioned with Terraform
- Region, availability zone, SSH IP, and public key hardcoded directly in `.tf` files
- Demonstrated: resource creation, data sources, outputs, instance state management

**Iteration 2 — Variables refactor**
- Extracted all environment-specific and sensitive values into `vars.tf`
- SSH IP and public key moved out of source files into `terraform.tfvars` (not committed)
- Added `terraform.tfvars.example` as a safe, committable template
- Added `.gitignore` to exclude state files, keys, and tfvars
- Demonstrated: input variables, variable types, tfvars pattern, secrets hygiene

---

## Security notes

- SSH access is restricted to a single IP via a `/32` CIDR rule — never open port 22 to `0.0.0.0/0` in production
- Private keys, `terraform.tfvars`, and state files are excluded from version control via `.gitignore`
- In a team or production environment, use remote state with S3 + DynamoDB locking instead of local state
- IMDSv2 is not enforced in this exercise config — enforce `http_tokens = "required"` in production to prevent SSRF attacks against instance metadata

---

## .gitignore

```gitignore
# Private keys
terra-key
terra-key.pub
*.pem

# Terraform state
terraform.tfstate
terraform.tfstate.backup
*.tfstate
*.tfstate.*

# Terraform variables (contains secrets)
terraform.tfvars
*.auto.tfvars

# Terraform working directory
.terraform/
```

---

## Related projects

- [containerization_project](https://github.com/Jaykol/containerization_project) — Docker + Kubernetes deployment
- [MarketPeak_Ecommerce](https://github.com/Jaykol/MarketPeak_Ecommerce) — EC2 deployment with Apache and Git workflow
- [hello-world-cicd](https://github.com/Jaykol/hello-world-cicd) — CI/CD pipeline with Jenkins and GitHub Actions