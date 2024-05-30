### VPC ###

resource "aws_vpc" "fp_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

### Internet Gateway ###

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.fp_vpc.id
  tags = {
    Name = var.igw_name
  }
}

### Public Route Table ###

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.fp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = var.pub_rt_name
  }
}

### Private Route Table ###

resource "aws_route_table" "priv_rt" {
  vpc_id = aws_vpc.fp_vpc.id
  tags = {
    Name = var.priv_rt_name
  }
}

### Public Route Table Association ###

resource "aws_route_table_association" "pub_rt_association" {
  for_each       = aws_subnet.pub_sub
  subnet_id      = each.value.id
  route_table_id = aws_route_table.pub_rt.id
}

### Private Route Table Association ###

resource "aws_route_table_association" "priv_rt_association" {
  for_each       = aws_subnet.priv_sub
  subnet_id      = each.value.id
  route_table_id = aws_route_table.priv_rt.id
}

### Public Subnets ### 

resource "aws_subnet" "pub_sub" {
  for_each          = var.public_subnet_object
  vpc_id            = aws_vpc.fp_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${each.value.name}-final-project"
  }
}

### Private Subnets ### 

resource "aws_subnet" "priv_sub" {
  for_each          = var.private_subnet_object
  vpc_id            = aws_vpc.fp_vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${each.value.name}-final-project"
  }
}
