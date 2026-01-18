# Look up existing VPC by name tag
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Look up private subnets by tag
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

# Default security group for the VPC
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.main.id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}
