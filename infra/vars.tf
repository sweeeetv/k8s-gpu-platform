variable "aws_region" {  default = "ap-southeast-2" }
variable "availability_zone" {default = "ap-southeast-2a" } //single az
variable "prefix" {default = "k8s-gpu"}
variable "tags" {
  default = {
    project     = "k8s-gpu-platform"
    env  = "dev"
  }
}

variable "key_pair_name" { //for ssh into the instance.
  description = "This registers a key pair in AWS and saves the private key locally."
}// create with:
// aws ec2 create-key-pair --key-name k8s-platform-key --query 'KeyMaterial' --output text > k8s-platform-key.pem
// chmod 400 k8s-platform-key.pem

variable "my_ip" { type  = string } //SSH and kubectl access are scoped to this only



# -------------- Networking / CIDR plan ------------------
# vpc_cidr, pod_cidr, and kubeadm CIDR (10.96.0.0/12) must not overlap. Checked: 10.60.0.0/16 (VPC) and 192.168.0.0/16 (pods) are both outside 10.96.0.0–10.111.255.255 (kubeadom default).

variable "vpc_cidr" { default = "10.60.0.0/16" }
variable "public_subnet_cidr" { default = "10.60.1.0/24" }
variable "pod_cidr" { //every pod gets an ip from this range, only exist because Calico (CNI plugin) creates them using Linux namespaces + virtual interfaces.
//passed to kubeadm init --pod-network-cidr later
  type        = string
  default     = "192.168.0.0/16"
}

# --- Compute ---------------
# A worker node is a VM with three extra programs installed on an instance.
# Most worker nodes are regular CPU VMs
# The kubelet on the worker node creates pods.
# For 95% of K8s workloads, it's just regular CPU VMs.

variable "control_plane_instance_type" {
  default = "t3.medium"  #(2 vCPU/4GB) is the practical minimum — kubeadm's preflight checks want 2 CPUs, which rules out free-tier t2/t3.micro. 
}
variable "cpu_worker_instance_type" {
  default = "t3.medium"
}

# --- GPU node bridge ------------------------
# this is when to use marketplace gpus:
variable "gpu_node_ip" {
  description = "Public IP of the rented GPU node, in CIDR form (e.g. 198.51.100.20/32), Leave null until after renting it and know its IP."
  type        = string
  default     = null
}

# spot instance
variable "gpu_worker_instance_type" {
  description = "Spot GPU instance type, e.g. g4dn.xlarge (1x T4)"
  type        = string
  default     = "g4dn.xlarge"
}

variable "gpu_spot_max_price" {
  description = "Max hourly price willing to pay for the GPU spot instance"
  type        = string
  default     = "0.30"
}
