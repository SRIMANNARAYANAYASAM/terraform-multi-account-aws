## AWS Multi-Account Terraform Architecture

### Overview

This project provisions a secure, production-grade AWS multi-account architecture using Terraform. It includes centralized state management, cross-account deployments, reusable modules, and governance controls via AWS Organizations.

---

### 🔧 Architecture Summary

- **Management Account**:
  - Hosts Terraform state backend (S3 + DynamoDB)
  - Runs Terraform CLI or CI/CD pipelines
  - Manages AWS Organizations, SCPs, and CloudTrail

- **Dev Member Account**:
  - Receives infrastructure via cross-account role
  - Deploys VPC using reusable modules

- **Governance**:
  - SCP prevents deletion of CloudTrail and logs
  - Organization-wide CloudTrail sends logs to central S3 bucket

---

### Architecture Diagrams


# Project Flowchart High-level overview of the provisioning sequence and Terraform execution flow across accounts.

Diagram/Project-work-flow.jpg



### ✅ Prerequisites

- AWS CLI authenticated to management account
- Terraform ≥ 1.3.0
- IAM role `OrganizationAccountAccessRole` exists in member accounts
- OU IDs retrieved from AWS Organizations

---

### 📁 Folder Structure

```bash
.
├── backend/                  # Provisions S3 + DynamoDB for remote state
│   ├── main.tf
│   └── variables.tf
│
├── environments/
│   ├── dev/                  # Dev environment deployment
│   │   ├── main.tf
│   │   ├── provider.tf
│   │   ├── backend.tf
│   │   └── variables.tf
│   └── prod/                 # (Future expansion)
│
├── modules/
│   └── vpc/                  # Reusable VPC module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── governance/              # SCP + CloudTrail setup
    ├── main.tf
    └── variables.tf
```

---

### 🔐 Remote State Setup (`backend/`)

- **S3 Bucket**: `bmahadik-terraform-state`
- **DynamoDB Table**: `terraform-lock-table`
- Enables versioning, encryption, and state locking

---

### 🚀 Dev Environment (`environments/dev/`)

- **Provider**: Assumes role into dev-member account
- **Module**: Deploys VPC using `modules/vpc`
- **Backend**: Points to central S3/DynamoDB
- **Variables**:
  - `cidr_block`: VPC CIDR range
  - `name`: VPC name tag
  - `dev_role_arn`: IAM role ARN for cross-account access

---

### 🧱 VPC Module (`modules/vpc/`)

- **main.tf**: Defines VPC resource
- **variables.tf**: Accepts CIDR and name
- **outputs.tf**: Exports VPC ID

---

### 🛡️ Governance (`governance/`)

- **SCP**: `DenyDeleteCloudTrail`
  - Prevents deletion of CloudTrail and S3 logs
- **CloudTrail**: `org-trail`
  - Multi-region, global service events, log validation
- **Central Logging Bucket**: `bmahadik-central-logs`
- **Bucket Policy**: Modularized in `variables.tf` and injected via `jsonencode()` in `main.tf`

---

### 🧠 How Terraform Works Here

- Terraform runs in the **management account**
- Assumes IAM role into **dev-member account**
- Uses **remote backend** for state consistency
- Applies **SCPs and CloudTrail** from management account

---

### ✅ Full Deployment Sequence

Run the following commands from the root of your repository to deploy all infrastructure in the correct order:

```bash
# Step 1: Setup remote backend
terraform -chdir=backend init
terraform -chdir=backend plan
terraform -chdir=backend apply -auto-approve

# Step 2: Deploy governance (SCPs + CloudTrail)
terraform -chdir=governance init
terraform -chdir=governance plan
terraform -chdir=governance apply -auto-approve

# Step 3: Deploy dev environment (VPC in dev-member account)
terraform -chdir=environments/dev init
terraform -chdir=environments/dev plan
terraform -chdir=environments/dev apply -auto-approve
```

---

### 🔥 Full Teardown Sequence

To destroy all resources in reverse order:

```bash
# Step 1: Destroy dev environment
terraform -chdir=environments/dev destroy -auto-approve

# Step 2: Remove governance controls
terraform -chdir=governance destroy -auto-approve

# Step 3: Tear down remote backend
terraform -chdir=backend destroy -auto-approve
```

---

### 🧠 Notes

- Each folder is treated as an isolated Terraform workspace.
- `-chdir` allows you to run commands from the root without manually navigating into folders.
- Always destroy in reverse order to avoid dependency issues (e.g., SCPs blocking resource deletion).
- You can wrap these commands into a `deploy.sh` and `destroy.sh` script for automation.
- `prod/` folder is scaffolded for future expansion.
- All modules and environments are fully parameterized.
- SCPs and CloudTrail are enforced organization-wide.

---

### 🧩 Common Errors faced & Fixes

#### ❌ DynamoDB Table Not Found After Backend Apply
- **Cause**: Wrong AWS region selected in Console.
- **Fix**: DynamoDB is region-specific. Switch to the region defined in your provider block (e.g., `us-east-2`).

#### ❌ SCP Attach Error: `PolicyTypeNotEnabledException`
- **Cause**: SCPs not enabled in AWS Organizations.
- **Fix**:
  1. Go to AWS Console → Organizations → Policies.
  2. Click “Enable service control policies.”

#### ❌ CloudTrail Error: `InsufficientS3BucketPolicyException`
- **Cause**: S3 bucket missing required permissions for CloudTrail.
- **Fix**: Add this bucket policy via Terraform:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck",
      "Effect": "Allow",
      "Principal": { "Service": "cloudtrail.amazonaws.com" },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::bmahadik-central-logs"
    },
    {
      "Sid": "AWSCloudTrailWrite",
      "Effect": "Allow",
      "Principal": { "Service": "cloudtrail.amazonaws.com" },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::bmahadik-central-logs/AWSLogs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
```

This policy is modularized in `variables.tf` and injected via `jsonencode()` in `main.tf`.

---

###🔧 What Could Be Improved

-Use Terraform Workspaces to separate dev/prod environments more cleanly instead of folder duplication.

-Add CI/CD integration (e.g., GitHub Actions) to automate plan/apply on commits or pull requests.

-Switch to role-based access using named IAM roles with least privilege instead of relying solely on OrganizationAccountAccessRole.

-Enable AWS Config for continuous compliance tracking and resource drift detection across accounts.

-Add tagging standards to enforce consistent metadata across all resources (owner, environment, cost center).

---

#### ❓ What Does `type = any` Mean in Terraform?
- **Explanation**: Allows a variable to accept any data type — string, list, map, object, etc.
- **Why Used**: Ideal for complex JSON blocks like bucket policies.
- **Tip**: Use `any` when flexibility is needed, but switch to `object` or `list(object(...))` for stricter validation.

