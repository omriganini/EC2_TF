variable "ssh_public_key" {
  description = "SSH public key for EC2 key pair"
  type        = string
  sensitive   = true
}
