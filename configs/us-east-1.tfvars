region   = "us-east-1"
name     = "my-n8n"
vpc_name = "my-vpc"

tags = {
  Environment = "production"
  Purpose     = "automation"
}

cloudflare_tunnel_token = "your-cloudflare-tunnel-token-here"