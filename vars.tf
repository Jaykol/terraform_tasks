variable "region" {
  default = "us-east-1"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "amiID" {
  default = {
    "us-east-1" = "ami-068c0051b15cdb816"
    "us-west-2" = "ami-0ebf411a80b6b22cb"
  }
}

variable "ssh_ip" {
  description = "Your IP address for SSH access (e.g. 203.0.113.5/32)"
  type        = string
}

variable "public_key" {
  description = "SSH public key to register with AWS"
  type        = string
}
