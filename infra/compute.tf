data "aws_ami" "ubuntu_id" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"] // HVM  (Hardware Virtual Machine) -> faster 
  }
}

resource "aws_instance" "control_plane" { 
  ami                    = data.aws_ami.ubuntu_id.id
  instance_type          = var.control_plane_instance_type
  subnet_id     = aws_subnet.public.id //control plane should be in the private subnet, but for simplicity, public subnet here.
  //how to talk to -> api server is usually explosed by:  NLB in public subnet (most common), bastion in the public subnet, or VPN. 
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.k8s_nodes.id]

  # Placeholder until cloud-init/control-plane.yaml exists (next file batch).
  # Swap to: user_data = file("${path.module}/../cloud-init/control-plane.yaml")
  user_data = <<-EOF
    #cloud-config
    package_update: true
  EOF

  root_block_device { // 30GB gp3 root volume, practical minimum for kubeadm's preflight checks.
    volume_size = 30
    volume_type = "gp3"
  }
  tags = {
    Name = "${var.prefix}-control-plane"
    Role = "control-plane"
  }
}

resource "aws_instance" "cpu_worker" {
  ami                    = data.aws_ami.ubuntu_id.id
  instance_type          = var.cpu_worker_instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.k8s_nodes.id]

  # Placeholder until cloud-init/worker.yaml exists (next file batch).
  # Swap to: user_data = file("${path.module}/../cloud-init/worker.yaml")
  user_data = <<-EOF
    #cloud-config
    package_update: true
  EOF

  root_block_device {
    volume_size = 30 //resize later if not enough
    volume_type = "gp3" //general-purpose SSD, middle ground in aws
  }

  tags = {
    Name = "${var.prefix}-worker"
    Role = "worker-node"
  }
}
