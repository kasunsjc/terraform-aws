#---Networking/main.tf

data "aws_availability_zones" "aws_az" {
}

resource "random_shuffle" "az_zone_list" {
  input        = data.aws_availability_zones.aws_az.names
  result_count = var.max_subnets
}

resource "random_integer" "random_int" {
  max = 100
  min = 1
}

resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "app-vpc-${random_integer.random_int.id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "app_public_subnet" {
  count                   = var.public_sn_count
  cidr_block              = var.public_cidrs[count.index]
  vpc_id                  = aws_vpc.app_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_zone_list.result[count.index]

  tags = {
    Name = "app-public-${count.index + 1}"
  }
}

resource "aws_subnet" "app_private_subnet" {
  count             = var.private_sn_count
  cidr_block        = var.private_cidrs[count.index]
  vpc_id            = aws_vpc.app_vpc.id
  availability_zone = random_shuffle.az_zone_list.result[count.index]

  tags = {
    Name = "app-private-${count.index + 1}"
  }
}

resource "aws_route_table_association" "app_public_association" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.app_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.app_public_rt.id
}


resource "aws_internet_gateway" "internet_igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "app-igw"
  }
}

resource "aws_route_table" "app_public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "app-public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.app_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_igw.id
}

resource "aws_default_route_table" "app_private_rt" {
  default_route_table_id = aws_vpc.app_vpc.default_route_table_id

  tags = {
    Name = "app-private-rt"
  }
}

resource "aws_security_group" "app_sg" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.app_vpc.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      protocol    = ingress.value.protocol
      to_port     = ingress.value.to
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

