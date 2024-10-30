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

resource "aws_route_table" "private_rtb" {
  count  = var.sub_count
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "test-private-rtb-${count.index}"
  }
}

resource "aws_route_table_association" "private_rtb_association" {
  count          = var.sub_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rtb[count.index].id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "S3 Gateway Endpoint"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_endpoint_route_table" {
  route_table_id  = aws_route_table.private_rtb[0].id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}