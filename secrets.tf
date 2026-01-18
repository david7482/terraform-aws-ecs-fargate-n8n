# Secrets Manager for Cloudflare Tunnel token
resource "aws_secretsmanager_secret" "cloudflare_tunnel_token" {
  name = "${var.name}-cloudflare-tunnel-token"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "cloudflare_tunnel_token" {
  secret_id     = aws_secretsmanager_secret.cloudflare_tunnel_token.id
  secret_string = var.cloudflare_tunnel_token
}
