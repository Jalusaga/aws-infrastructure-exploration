## AWS Infrastructure + Django REST API with Terraform & Ansible

> End-to-end provisioning: Terraform builds the AWS network, instances, and RDS; Ansible deploys and configures Nginx, Gunicorn, and a Django REST API with MySQL.

---

## 🏗️ Infrastructure Architecture

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
    │  │     (10.0.5.0/24)    │                      │     (10.0.0.0/24)    │    │
    │  │ ┌─────────────────┐  │                      │ ┌─────────────────┐  │    │
    │  │ │  EC2 + Nginx    │  │                      │ │   RDS / MySQL   │  │    │
    │  │ └─────────────────┘  │                      │ └─────────────────┘  │    │
    │  └──────────────────────┘                      └──────────────────────┘    │
    │                                                                            │
    │                                                ┌──────────────────────┐    │
    │                                                │  Private Subnet AZ-2 │    │
    │                                                │     (10.0.1.0/24)    │    │
    │                                                │ ┌─────────────────┐  │    │
    │                                                │ │   Idle/Spare    │  │    │
    │                                                │ └─────────────────┘  │    │
    │                                                └──────────────────────┘    │
    └────────────────────────────────────────────────────────────────────────────┘
```

This setup includes:

- A VPC across two AZs with public/private subnets
- An Internet Gateway and routing for the public subnet
- Security Groups restricting traffic:

  - **EC2_SG** allows HTTP/SSH from the internet
  - **DB_SG** allows MySQL only from the EC2_SG

- An RDS MySQL instance in the private subnet
- An EC2 instance running Nginx, Gunicorn, and Django in the public subnet

---

## 🔌 Prerequisites

1. **Terraform CLI** (v1.0+)
2. **AWS CLI** configured with appropriate IAM permissions
3. **Ansible** (ansible-core)
4. SSH key access to the EC2 (make sure `ansible_ssh_private_key_file` points to your `.pem`)

---

## ⚙️ Deployment Steps

### 1. Clone the repo

```bash
git clone https://github.com/jalusaga/aws-infrastructure-exploration.git
cd aws-infrastructure-exploration
```

### 2. Terraform: Provision AWS

1. Copy and customize variables:

   ```bash
   cd terraform
   cp variables.example.tf variables.tf
   # edit variables.tf: db_username, db_password, etc.
   ```

2. Initialize & apply:

   ```bash
   terraform init
   terraform apply -auto-approve
   ```

3. Note the outputs:

   ```bash
   terraform output web_public_ip   # EC2 public IPv4
   terraform output db_endpoint     # RDS endpoint
   ```

### 3. Ansible: Configure the EC2 & Deploy Django App

1. Copy inventory template and fill in your SSH key path:

   ```bash
   cp ansible/inventory.ini.example ansible/inventory.ini
   # edit ansible/inventory.ini:
   # ansible_ssh_private_key_file = ~/.ssh/aws-infrastructure-exploration.pem
   ```

2. Run the playbook:

   ```bash
   cd ansible
   ansible-playbook -i inventory.ini site.yml
   ```

This will:

- Install system packages (Nginx, Python3, pip, etc.)
- Create a Python venv and install requirements
- Render and enable the `.env` with DB credentials & ALLOWED_HOSTS
- Run Django migrations and collectstatic
- Create a default superuser (`testuser` / `PasswordTest12345*`)
- Configure & start Gunicorn (systemd unit)
- Upload Nginx site config and reload

---

## 🚀 Testing the Deployment

1. **Django login API**

   ```bash
   curl -i -X POST http://$(terraform output -raw web_public_ip)/api/auth/login/ \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser","password":"PasswordTest12345*"}'
   # should return 200 OK + {"token":"..."}
   ```

2. **Access admin site**
   Visit `http://<EC2_PUBLIC_IP>/admin/`, log in as `testuser`.

---

## 🧹 Cleanup

1. Destroy AWS resources:

   ```bash
   terraform destroy -auto-approve
   ```
