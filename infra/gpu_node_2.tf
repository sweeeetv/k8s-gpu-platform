# This is for renting gpu units from Vast.ai or
# RunPod (spot/community pricing, roughly $0.15-0.75/hr for an RTX 4090)
# and manually kubeadm-joined — mirroring how a real bare-metal GPU node
# gets added to a cluster, rather than auto-joining via a managed node
# pool API.
#
#
# Session workflow:
#   1. Rent the GPU box, note its public IP
#   2. Set gpu_node_ip in terraform.tfvars, `make apply`
#   3. SSH into the GPU box, run scripts/03-join-gpu-worker.sh
#   4. Done for the session: terminate the rented box, then
#      `make destroy-gpu` to close these holes again
#

resource "aws_security_group_rule" "gpu_node_to_api" {
  count             = var.gpu_node_ip == null ? 0 : 1
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  security_group_id = aws_security_group.k8s_nodes.id
  cidr_blocks       = [var.gpu_node_ip]
  description       = "GPU node - API server"
}

resource "aws_security_group_rule" "gpu_node_kubelet" {
  count             = var.gpu_node_ip == null ? 0 : 1
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  security_group_id = aws_security_group.k8s_nodes.id
  cidr_blocks       = [var.gpu_node_ip]
  description       = "control-plane - GPU node kubelet"
}

resource "aws_security_group_rule" "gpu_node_bgp" {
  count             = var.gpu_node_ip == null ? 0 : 1
  type              = "ingress"
  from_port         = 179
  to_port           = 179
  protocol          = "tcp"
  security_group_id = aws_security_group.k8s_nodes.id
  cidr_blocks       = [var.gpu_node_ip]
  description       = "Calico BGP session with GPU node"
}

# NOTE: if Calico ends up using IP-in-IP or VXLAN encapsulation instead of
# unencapsulated BGP for the GPU node link, add the matching protocol/port
# here once that's settled in scripts/04-install-calico.sh.
