# AWS Infra Exploration with Terraform

> Putting Terraform through its paces: we’re building a VPC with two AZs, carving out public & private subnets, standing up an Nginx-powered EC2 in the public subnet, and hiding our database in the private subnet—complete with an Internet Gateway, routing tables, and all the security goodies.

---

## 🏗️ Architecture Overview

```text
                                      ┌──────────┐
                                      │ Internet │
                                      └────┬─────┘
                                           │
                                  ┌────────▼────────┐
                                  │  Internet GW    │
                                  └────────┬────────┘
                                           │
    ┌──────────────────────────────────────┴─────────────────────────────────────┐
    │                                   VPC                                      │
    │                             (10.0.0.0/16)                                  │
    │  ┌──────────────────────┐                      ┌──────────────────────┐    │
    │  │  Public Subnet AZ-1  │                      │  Private Subnet AZ-1 │    │
    │  │     (10.0.5.0/24)    │                      │     (10.0.1.0/24)    │    │
    │  │ ┌─────────────────┐  │                      │ ┌─────────────────┐  │    │
    │  │ │  EC2 + Nginx    │  │                      │ │   RDS / DB      │  │    │
    │  │ └─────────────────┘  │                      │ └─────────────────┘  │    │
    │  └──────────────────────┘                      └──────────────────────┘    │
    │                                                                            │
    │                                                ┌──────────────────────┐    │
    │                                                │  Private Subnet AZ-2 │    │
    │                                                │     (10.0.2.0/24)    │    │
    │                                                │                      │    │
    │                                                └──────────────────────┘    │
    └────────────────────────────────────────────────────────────────────────────┘
```

## 🔌 Prerequisites

1. Terraform CLI (v1.0+ recommended) installed locally

2. AWS CLI configured with an IAM user / role that can create VPCs, EC2, RDS (or whatever DB you chose), SGs, etc.

3. A bit of patience—Terraform will spin up real AWS resources (so costs do apply).

## ⚙️ Getting Started

1. Cloning the repo

```bash
git clone https://github.com/YourUsername/aws-infra-exploration.git
cd aws-infra-exploration
```

2. Review & customize

- Rename the variables.tf file

```bash
mv variables.tf.copy variables.tf
```

- variables.tf: double-check defaults (region, instance type, DB engine/version/credentials, subnet CIDRs)

3. Initialize Terraform

```bash
terraform init
```

4. See what's going to happen

```bash
terraform plan
```

5. Apply the changes

```bash
terraform apply
#type yes when prompted
```

### After a few minutes you’ll have:

- A VPC spanning two AZs

- - Public subnets (one in each AZ) with an Internet Gateway & route tables

- - Private subnets (one in each AZ) for your RDS/DB

- - Security Groups locking down traffic:

- - - EC2_SG allows HTTP (80) from anywhere

- - - DB_SG only allows DB port from the EC2’s SG

- - An EC2 instance running Nginx in the public subnet

- - A managed database in the private subnet

## 🚀 Testing & Usage

1. Grab the EC2 public IP from Terraform’s outputs.

2. Open your browser to http://<EC2_PUBLIC_IP>—you should see the default Nginx welcome page.

3. From your EC2, try connecting to the database endpoint (shown in Terraform outputs) on port your chosen port.

## 🧹 Cleanup

When you're done playing around:

```bash
terraform destroy
# Type “yes” when prompted
```
