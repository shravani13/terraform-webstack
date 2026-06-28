resource "aws_vpc" "main"{
	cidr_block = var.vpc_cidr
	enable_dns_hostnames = true
	tags = {Name = "${var.environment}" }

}

resource "aws_subnet" "public_1"{
	vpc_id = aws_vpc.main.id
	cidr_block = var.public_1_cidr
	map_public_ip_on_launch = true
	availability_zone = "${var.aws_region}a"
}

resource "aws_subnet" "public_2"{
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_2_cidr
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}b"
}

resource "aws_subnet" "private"{
        vpc_id = aws_vpc.main.id
        cidr_block = var.private_cidr
        map_public_ip_on_launch = false
        availability_zone = "${var.aws_region}b"
}

resource "aws_internet_gateway" "ig_gateway" {
        vpc_id = aws_vpc.main.id
        tags = { Name = "${var.environment}-ig-gateway" }

}

/*resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig_gateway.id
  }
  tags = { Name = "${var.environment}-public-rt" }

}

resource "aws_route_table_association" "public_association"{
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_route.id

}
*/

# 1. Clean up Public Route Table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.environment}-public-rt" }
}

# Explicit standalone resource for Public Route
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig_gateway.id
}

resource "aws_route_table_association" "public_association"{
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_route.id

}


resource "aws_eip" "nat_eip"{
	domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway"{
	allocation_id = aws_eip.nat_eip.id
	subnet_id = aws_subnet.public_1.id
	tags = { Name ="${var.environment}-nat-gw"}
}

/*
resource "aws_route_table" "private_route"{
	vpc_id = aws_vpc.main.id
	route{
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = aws_nat_gateway.nat_gateway.id
	}
	tags = { Name = "${var.environment}-private-rt" }
}

resource "aws_route_table_association" "private_association" {
        subnet_id = aws_subnet.private.id
        route_table_id = aws_route_table.private_route.id
}*/

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.environment}-private-rt" }
}

# Explicit standalone resource for Private NAT Route
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private_route.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id # Natively using nat_gateway_id
}

resource "aws_route_table_association" "private_association" {
        subnet_id = aws_subnet.private.id
        route_table_id = aws_route_table.private_route.id
}
