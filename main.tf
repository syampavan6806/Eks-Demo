resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common-tags,
    {
      "Name"                                              = "${var.project_name}-vpc",
      "kubernetes.io/cluster/${var.project_name}-cluster" = "shared"
  })
}

resource "aws_subnet" "publicsubnets" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.public_subnet_cidrs)
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.availabilityzones.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common-tags,
    {
      "Name"                                              = "${var.project_name}-public-subnet-${count.index + 1}",
      "kubernetes.io/cluster/${var.project_name}-cluster" = "shared",
      "kubernetes.io/role/elb"                            = "1"
  })
}

resource "aws_subnet" "privatesubnets" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.private_subnet_cidrs)
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.availabilityzones.names[count.index]

  tags = merge(var.common-tags,
    {
      "Name"                                              = "${var.project_name}-private-subnet-${count.index + 1}",
      "kubernetes.io/cluster/${var.project_name}-cluster" = "shared",
      "kubernetes.io/role/internal-elb"                   = "1"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common-tags,
    {
      "Name" = "${var.project_name}-igw"

  })
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.common-tags,

    {
      "Name" = "${var.project_name}-public-rt"

  })

}

resource "aws_route_table_association" "public-rt-association" {
  count     = length(var.public_subnet_cidrs)
  subnet_id = element(aws_subnet.publicsubnets[*].id, count.index)
  #subnet_id      = aws_subnet.publicsubnets[count.index].id
  route_table_id = aws_route_table.public-rt.id

}

resource "aws_eip" "nateip" {
  domain = "vpc"
  tags = merge(var.common-tags,
    {
      "Name" = "${var.project_name}-nat-eip"
  })
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nateip.id
  subnet_id     = aws_subnet.publicsubnets[0].id

  tags = {
    Name = "${var.project_name}-NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = merge(var.common-tags,

    {
      "Name" = "${var.project_name}-private-rt"

  })

}

resource "aws_route_table_association" "private-rt-association" {
  count          = length(var.private_subnet_cidrs)
  route_table_id = aws_route_table.private-rt.id
  subnet_id      = element(aws_subnet.privatesubnets[*].id, count.index)
  #subnet_id      = aws_subnet.privatesubnets[count.index].id

}





