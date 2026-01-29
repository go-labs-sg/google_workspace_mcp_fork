resource "aws_route_table" "public_rt" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.igw_id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = local.vpc_id
  cidr_block        = local.public_subnet_1_cidr_block
  availability_zone = local.availability_zone_a

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet-1"
  })
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = local.vpc_id
  cidr_block        = local.public_subnet_2_cidr_block
  availability_zone = local.availability_zone_b

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet-2"
  })
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = local.vpc_id
  cidr_block        = local.private_subnet_1_cidr_block
  availability_zone = local.availability_zone_a
  tags = {
    Name = "${local.name_prefix}-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = local.vpc_id
  cidr_block        = local.private_subnet_2_cidr_block
  availability_zone = local.availability_zone_b
  tags = {
    Name = "${local.name_prefix}-private-subnet-2"
  }
}

resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = local.vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = local.nat_network_interface_id
  }

  tags = {
    Name = "${local.name_prefix}-private-route-table"
  }
}

resource "aws_route_table_association" "private_rt_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}
