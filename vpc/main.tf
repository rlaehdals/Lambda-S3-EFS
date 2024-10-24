//디폴트 외 별도의 vpc 1개 생성
resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true

  tags = {
    Name        = "test-vpc"
  }
}


data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_subnet" "private_subnet" {
  count             = var.sub_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, (count.index * 32))
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  tags = {
    "Name" = "test-private-subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = var.sub_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, (count.index + 3) * 32)
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "test-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "test-gw"
  }
}


# ! public_rtb
resource "aws_route_table" "public_rtb" {
  count  = var.sub_count
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "test-public-rtb-${count.index}"
  }
}

resource "aws_egress_only_internet_gateway" "egress" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.sub_count
  route_table_id         = aws_route_table.public_rtb[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rtb" {
  count          = var.sub_count
  route_table_id = aws_route_table.public_rtb[count.index].id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}


# ! private_rtb
resource "aws_eip" "eip" {
  tags = {
    Name = "test-eip"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id     = aws_eip.eip.id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public_subnet[0].id
  tags = {
    Name = "test-natgw"
  }

  depends_on = [
    aws_internet_gateway.igw
  ]
}



resource "aws_route_table" "private_rtb" {
  count  = var.sub_count
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "test-private-rtb-${count.index}"
  }
}

resource "aws_route" "nat_gateway" {
  count                  = var.sub_count
  route_table_id         = aws_route_table.private_rtb[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
}

resource "aws_route_table_association" "private_rtb_association" {
  count          = var.sub_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rtb[count.index].id
}



