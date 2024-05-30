### VPC ###

resource "aws_vpc" "fp_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "final-project-vpc"
  }
}

### Internet Gateway ###

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.fp_vpc.id
  tags = {
    Name = "final-project-internet-gateway"
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
    Name = "final-project-public-route-table"
  }
}

### Public Route Table Association ###

resource "aws_route_table_association" "pub_rt_association_1" {
  subnet_id      = aws_subnet.pub_sub_1.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pub_rt_association_2" {
  subnet_id      = aws_subnet.pub_sub_2.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pub_rt_association_3" {
  subnet_id      = aws_subnet.pub_sub_3.id
  route_table_id = aws_route_table.pub_rt.id
}

### VPC Public Subnets ### ***USE FOR EACH ON FINAL VERSION ***

resource "aws_subnet" "pub_sub_1" {
  vpc_id            = aws_vpc.fp_vpc.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet-1-final-project"
  }
}

resource "aws_subnet" "pub_sub_2" {
  vpc_id            = aws_vpc.fp_vpc.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-subnet-2-final-project"
  }
}

resource "aws_subnet" "pub_sub_3" {
  vpc_id            = aws_vpc.fp_vpc.id
  cidr_block        = "10.0.32.0/20"
  availability_zone = "us-east-1c"

  tags = {
    Name = "public-subnet-3-final-project"
  }
}

### VPC Private Subnets ### ***USE FOR EACH ON FINAL VERSION ***

resource "aws_subnet" "priv_sub_1" {
  vpc_id            = aws_vpc.fp_vpc.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1-final-project"
  }
}

resource "aws_subnet" "priv_sub_2" {
  vpc_id            = aws_vpc.fp_vpc.id
  cidr_block        = "10.0.144.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-2-final-project"
  }
}

resource "aws_subnet" "priv_sub_3" {
  vpc_id            = aws_vpc.fp_vpc.id
  cidr_block        = "10.0.160.0/20"
  availability_zone = "us-east-1c"

  tags = {
    Name = "private-subnet-3-final-project"
  }
}