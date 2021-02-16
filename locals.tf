locals {
  vpc_cidr = "10.10.0.0/16"
}

locals {
  security_groups = {
    public = {
      name = "public_sg"
      description = "Public Security Group"
      ingress = {
        ssh = {
          from = 22
          to = 22
          protocol = "tcp"
          cidr_blocks = [var.access_ip]
        }
      }
    }
  }
}
