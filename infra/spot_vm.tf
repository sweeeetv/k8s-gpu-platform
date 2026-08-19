resource "aws_instance" "gpu_worker" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.gpu_worker_instance_type   # e.g. "g4dn.xlarge"

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price                      = var.gpu_spot_max_price
      spot_instance_type             = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }

  subnet_id              = aws_subnet.public.id
  key_name                = var.key_pair_name
  vpc_security_group_ids  = [aws_security_group.k8s_nodes.id]

  user_data = <<-EOF
    #cloud-config
    package_update: true
  EOF

  root_block_device {
    volume_size = 60   # bump from 30 — CUDA/driver images are large
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.prefix}-gpu-worker"
    Role = "gpu-worker"
  }
}