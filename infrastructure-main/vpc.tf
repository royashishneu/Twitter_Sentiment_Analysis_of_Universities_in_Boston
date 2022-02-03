resource "aws_vpc" "csye7200" {
  cidr_block                       = var.vpc_cidr_block
  enable_dns_hostnames             = true
  enable_dns_support               = true
  enable_classiclink_dns_support   = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "csye7200-team5-vpc"
  }
}

resource "aws_subnet" "subnet" {
  for_each = local.subnet_az_cidr

  cidr_block              = each.value
  vpc_id                  = aws_vpc.csye7200.id
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = {
    Name = "csye7200-subnet"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.csye7200.id

  tags = {
    Name = "csye7200-internet-gateway"
  }
}

resource "aws_route_table" "csye7200-rt" {
  vpc_id = aws_vpc.csye7200.id

  route = []

  tags = {
    Name = "csye7200-rt"
  }
}

resource "aws_route" "csye7200-r" {
  route_table_id         = aws_route_table.csye7200-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_route_table_association" "csye7200-a" {
  for_each       = aws_subnet.subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.csye7200-rt.id
}

