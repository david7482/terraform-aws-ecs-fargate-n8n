variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "david74"
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "name" {
  description = "Base name for all resources"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# VPC
variable "vpc_name" {
  description = "Name tag of the existing VPC"
  type        = string
}

# ECS Task
variable "container_image" {
  description = "Container image for n8n"
  type        = string
  default     = "n8nio/n8n:latest"
}

variable "container_port" {
  description = "Port exposed by the n8n container"
  type        = number
  default     = 5678
}

variable "task_cpu" {
  description = "CPU units for the task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Memory for the task in MB"
  type        = number
  default     = 1024
}

variable "container_environment" {
  description = "Environment variables for the n8n container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# ECS Service
variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 1
}

# CloudWatch
variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 7
}

# Cloudflare Tunnel
variable "cloudflare_tunnel_token" {
  description = "Cloudflare Tunnel token"
  type        = string
  sensitive   = true
}
