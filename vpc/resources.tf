### VPC ###

resource "aws_vpc" "fp_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "final-project-vpc"
  }
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

resource "aws_subnet" "pub_sub_3" {
  vpc_id            = aws_vpc.fp_vpc.id
  cidr_block        = "10.0.160.0/20"
  availability_zone = "us-east-1c"

  tags = {
    Name = "private-subnet-3-final-project"
  }
}