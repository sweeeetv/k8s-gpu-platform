output "control_plane_public_ip" { value = aws_instance.control_plane.public_ip }
output "control_plane_private_ip" {value = aws_instance.control_plane.private_ip }

output "cpu_worker_public_ip" { value = aws_instance.cpu_worker.public_ip}

output "cpu_worker_private_ip" {value = aws_instance.cpu_worker.private_ip}

output "security_group_id" {value = aws_security_group.k8s_nodes.id}

output "pod_cidr" {
  description = "Read by scripts/01-init-control-plane.sh for kubeadm init --pod-network-cidr"
  value       = var.pod_cidr
}