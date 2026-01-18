# EFS File System for n8n data persistence
resource "aws_efs_file_system" "n8n" {
  creation_token   = var.name
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = merge(var.tags, {
    Name = var.name
  })
}

# Security group for EFS - allows NFS from ECS tasks
resource "aws_security_group" "efs" {
  name        = "${var.name}-efs"
  description = "Allow NFS traffic from ECS tasks"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description     = "NFS from ECS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [data.aws_security_group.default.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-efs"
  })
}

# EFS Mount Targets in private subnets
resource "aws_efs_mount_target" "n8n" {
  for_each = toset(data.aws_subnets.private.ids)

  file_system_id  = aws_efs_file_system.n8n.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

# EFS Access Point for n8n
resource "aws_efs_access_point" "n8n" {
  file_system_id = aws_efs_file_system.n8n.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/n8n-data"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-access-point"
  })
}
