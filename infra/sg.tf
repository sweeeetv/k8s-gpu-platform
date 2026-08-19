
# Covers node-to-node cluster traffic (etcd, kubelet, Calico, etc.) between
# the AWS-side nodes without enumerating every port individually — standard
# pattern for a single-SG cluster like this one.

resource "aws_security_group" "k8s_nodes" {
  name        = "k8s-gpu-platform-nodes"
  description = "AWS-side cluster nodes (control-plane, cpu-worker)"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "k8s-gpu-platform-nodes-sg" }
}

resource "aws_security_group_rule" "nodes_self_all" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.k8s_nodes.id
  source_security_group_id = aws_security_group.k8s_nodes.id
  description               = "All traffic between AWS-side cluster nodes"
}

resource "aws_security_group_rule" "ssh_from_me" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.k8s_nodes.id
  cidr_blocks       = [var.my_ip]
  description       = "SSH from my IP only"
}

resource "aws_security_group_rule" "k8s_api_from_me" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  security_group_id = aws_security_group.k8s_nodes.id
  cidr_blocks       = [var.my_ip]
  description       = "kubectl access to the API server from my IP"
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.k8s_nodes.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Unrestricted egress"
}
