# Terraform: EC2 (MySQL) + RDS (MySQL) via GitHub Actions

This repository is a minimal example that provisions **two resources in AWS** using Terraform, executed by a **GitHub Actions** pipeline:

- An **EC2 instance** running **MySQL in Docker** (single-container MySQL on the VM)
- An **RDS MySQL instance**

> ⚠️ Cost note: RDS is **not free** in most accounts. Remember to run `terraform destroy` to avoid ongoing charges.

---

## What it creates

Terraform will create:

- Security groups:
  - `ec2_mysql_sg` (allows SSH from your `allowed_cidr`, and MySQL 3306 from your `allowed_cidr`)
  - `rds_mysql_sg` (allows MySQL 3306 **from the EC2 security group**)
- An EC2 instance in the **default VPC** with:
  - Docker installed
  - A MySQL container started at boot (port 3306)
- An RDS MySQL instance in the **default VPC** with:
  - A DB subnet group (based on default subnets)
  - Randomly generated master password (stored in Terraform state)
  - Optional: public accessibility controlled by `rds_publicly_accessible` (default: `false`)

---

## Prerequisites

1. An AWS account.
2. An IAM principal with permissions to create:
   - EC2 (instance, security groups)
   - RDS (instance, subnet group)
   - VPC read access (to query default VPC/subnets)
3. GitHub repository secrets (see below).

---

## Repository structure

- `terraform/`  
  Terraform configuration (providers, resources, variables, outputs)
- `.github/workflows/terraform.yml`  
  GitHub Actions pipeline to run `terraform init/plan/apply`

---

## Required GitHub Secrets

Configure these secrets in your GitHub repository:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` (example: `us-east-1`)

> Recommended (more secure): use GitHub OIDC instead of static keys. This sample keeps it simple.

---

## Terraform variables

The pipeline reads Terraform variables using environment variables (`TF_VAR_*`).

### Required

- `TF_VAR_allowed_cidr`  
  CIDR allowed to access:
  - EC2 SSH (22)
  - EC2 MySQL (3306)  
  Example: `203.0.113.10/32`

### Optional (with defaults)

- `TF_VAR_project` (default: `demo`)
- `TF_VAR_instance_type` (default: `t3.micro`)
- `TF_VAR_mysql_container_password` (default: `ChangeMe123!`)
- `TF_VAR_rds_instance_class` (default: `db.t3.micro`)
- `TF_VAR_rds_allocated_storage` (default: `20`)
- `TF_VAR_rds_publicly_accessible` (default: `false`)

You can also pass:
- `TF_VAR_key_name` (optional) — existing EC2 Key Pair name if you want SSH key access.

---

## How to run (GitHub Actions)

This workflow is configured for **manual execution only** using `workflow_dispatch`.

1. Push this repository to GitHub
2. Configure the **Secrets** listed above
3. Go to **Actions** → **Terraform Apply (EC2 + MySQL + RDS)** → **Run workflow**

The pipeline will:
- `terraform fmt -check`
- `terraform init`
- `terraform validate`
- `terraform plan`
- `terraform apply -auto-approve`

---

## Change the trigger to run on `main`

Currently, `.github/workflows/terraform.yml` uses only `workflow_dispatch`.

To run on pushes to `main`, change:

```yaml
on:
  workflow_dispatch:
```

to:

```yaml
on:
  push:
    branches: [ "main" ]
  workflow_dispatch:
```

---

## Outputs

After apply, Terraform outputs:

- `ec2_public_ip` (if the instance has a public IP)
- `rds_endpoint`
- `rds_port`

You can view outputs in the GitHub Actions logs.

---

## Cleanup

To destroy everything, run the workflow with `DESTROY=true` (see workflow input), or run locally:

```bash
cd terraform
terraform destroy -auto-approve
```

---

## Local execution (optional)

If you want to run locally:

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

Set your variables via environment:

```bash
export AWS_REGION=us-east-1
export TF_VAR_allowed_cidr="203.0.113.10/32"
terraform apply -auto-approve
```
