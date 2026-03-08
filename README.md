# chess-ai-infra

<<<<<<< HEAD
PR-04: Global Terraform (remote state + VPC)

## Stacks

- `bootstrap/`: Creates S3 bucket (versioned, SSE-S3) and DynamoDB table for Terraform remote state & locks.
- `global/`: Provisions a VPC (public + private subnets across 2 AZs, single NAT gateway for cost).

## Region

Default: `ap-south-1`. Change via `-var 'aws_region=...'`.

## Apply Order

1. **Bootstrap**
   ```bash
   cd bootstrap
   terraform init
   terraform apply -auto-approve \
     -var 'project=chess-ai' \
     -var 'aws_region=ap-south-1' \
     -var 'state_bucket_name=<globally-unique-bucket-name>' \
     -var 'lock_table_name=chess-ai-tf-lock'
=======
>>>>>>> origin/main
