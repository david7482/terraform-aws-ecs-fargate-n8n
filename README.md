# Terraform AWS ECS Fargate n8n

Terraform module to deploy [n8n](https://n8n.io/) (workflow automation platform) on AWS ECS Fargate with persistent storage and Cloudflare Tunnel integration.

## Architecture

This module deploys the following infrastructure:

- **ECS Fargate Cluster** - Runs n8n using Fargate Spot for cost optimization
- **ARM64 Architecture** - Uses ARM-based containers for better performance and lower costs
- **EFS File System** - Encrypted persistent storage for n8n workflows and data
- **Cloudflare Tunnel** - Secure external access without requiring an ALB or public-facing endpoints
- **CloudWatch Logs** - Centralized logging for both n8n and Cloudflare Tunnel containers
- **IAM Roles** - Properly scoped execution and task roles
- **AWS Secrets Manager** - Secure storage for Cloudflare Tunnel token

The deployment runs in an existing VPC's private subnets without requiring public IP addresses, using Cloudflare Tunnel for external connectivity.

## Features

- **Cost-Optimized**: Uses Fargate Spot instances (up to 70% savings) with ARM64 architecture
- **Secure**: Runs in private subnets, no public IPs, secrets managed via AWS Secrets Manager
- **Persistent Storage**: EFS ensures workflow data survives container restarts
- **Zero Public Exposure**: Cloudflare Tunnel provides secure external access without ALB
- **Scalable**: Easy to adjust CPU/memory and task count
- **Observable**: CloudWatch Logs integration for monitoring and debugging

## Prerequisites

- AWS Account with appropriate permissions
- Existing VPC with private subnets (tagged with `*private*` in the Name)
- Terraform >= 1.0
- Cloudflare Tunnel token (create via Cloudflare Zero Trust dashboard)

## Quick Start

1. **Clone or reference this module**

2. **Create a `.tfvars` file** (see `configs/us-east-1.tfvars` as example):

```hcl
region   = "us-east-1"
name     = "my-n8n"
vpc_name = "my-vpc"

tags = {
  Environment = "production"
  Purpose     = "automation"
}

cloudflare_tunnel_token = "your-cloudflare-tunnel-token-here"
```

3. **Initialize Terraform**:

```bash
terraform init
```

4. **Review the plan**:

```bash
terraform plan -var-file=configs/your-config.tfvars
```

5. **Apply**:

```bash
terraform apply -var-file=configs/your-config.tfvars
```

## Configuration

### Required Variables

| Variable | Description |
|----------|-------------|
| `region` | AWS region where resources will be created |
| `name` | Base name for all resources |
| `vpc_name` | Name tag of the existing VPC |
| `cloudflare_tunnel_token` | Cloudflare Tunnel token for secure external access |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_profile` | `"david74"` | AWS profile to use for authentication |
| `tags` | `{}` | Additional tags to apply to all resources |
| `container_image` | `"n8nio/n8n:latest"` | Container image for n8n |
| `container_port` | `5678` | Port exposed by the n8n container |
| `task_cpu` | `512` | CPU units for the task (256, 512, 1024, 2048, 4096) |
| `task_memory` | `1024` | Memory for the task in MB |
| `desired_count` | `1` | Number of tasks to run |
| `log_retention_days` | `7` | Number of days to retain CloudWatch logs |
| `container_environment` | `[]` | Environment variables for the n8n container |

### Environment Variables Example

```hcl
container_environment = [
  {
    name  = "N8N_BASIC_AUTH_ACTIVE"
    value = "true"
  },
  {
    name  = "N8N_BASIC_AUTH_USER"
    value = "admin"
  },
  {
    name  = "WEBHOOK_URL"
    value = "https://your-n8n-domain.com"
  }
]
```

## Cloudflare Tunnel Setup

1. Log in to [Cloudflare Zero Trust](https://one.dash.cloudflare.com/)
2. Navigate to **Access** > **Tunnels**
3. Create a new tunnel and note the token
4. Configure the tunnel to route your domain to `http://localhost:5678`
5. Use the tunnel token in your `.tfvars` file

## Remote State

This module uses S3 backend for state management. Update `backend.tf` with your own S3 bucket:

```hcl
terraform {
  backend "s3" {
    profile = "your-profile"
    region  = "us-west-2"
    bucket  = "your-terraform-state-bucket"
    key     = "terraform.tfstate"
    encrypt = true
    workspace_key_prefix = "terraform-aws-ecs-fargate-n8n"
  }
}
```

## Cost Optimization

- Uses **Fargate Spot** for up to 70% cost savings compared to on-demand Fargate
- **ARM64 architecture** provides 20% better price-performance compared to x86
- **EFS throughput mode** set to bursting (only pay for storage)
- Adjust `task_cpu` and `task_memory` based on your workflow needs

Estimated monthly cost for default configuration (us-east-1):
- ECS Fargate Spot (ARM64, 0.5 vCPU, 1GB RAM, running 24/7): ~$5-7/month
- EFS (5GB storage): ~$1.50/month
- CloudWatch Logs (minimal usage): ~$0.50/month
- Total: **~$7-9/month**

## Accessing n8n

Once deployed, access n8n through your Cloudflare Tunnel domain. The n8n web interface runs on port 5678 internally but is accessible via your configured Cloudflare domain.

## Monitoring

View logs in CloudWatch:

```bash
aws logs tail /ecs/your-n8n-name --follow
```

Or use the AWS Console to view logs for both n8n and cloudflared containers.

## Cleanup

To destroy all resources:

```bash
terraform destroy -var-file=configs/your-config.tfvars
```

## Security Considerations

- n8n runs in private subnets with no public IP
- EFS is encrypted at rest
- Cloudflare Tunnel token stored securely in AWS Secrets Manager
- Consider enabling n8n basic auth or more robust authentication
- Review and restrict IAM role permissions as needed
- Keep the Cloudflare Tunnel token secure (marked as sensitive in variables)

## License

This project is open source and available under the MIT License.
