# CloudWatch Log Group for n8n container logs
resource "aws_cloudwatch_log_group" "n8n" {
  name              = "/aws/ecs/${var.name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}
