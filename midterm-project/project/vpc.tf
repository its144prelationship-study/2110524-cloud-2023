// 1. VPC
resource "aws_vpc" "wordpress_vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "wordpress_vpc"
    }
}
//
# resource "aws_vpc_endpoint" "wordpress_vpc_endpoint" {
#     vpc_id = aws_vpc.wordpress_vpc.id
#     service_name = "com.amazonaws.${var.region}.s3"
#     route_table_ids = [aws_route_table.public_route_table.id]
# }
// 2. Subnet
resource "aws_subnet" "wordpress_public_subnet" {
    depends_on = [aws_vpc.wordpress_vpc, aws_internet_gateway.wordpress_igw]
    vpc_id = aws_vpc.wordpress_vpc.id
    cidr_block = var.wordpress_public_subnet_cidr
    availability_zone = var.availability_zone
    tags = {
      Name = "wordpress_public_subnet"
    }
}
resource "aws_subnet" "wordpress_private_subnet" {
    depends_on = [aws_vpc.wordpress_vpc]
    vpc_id = aws_vpc.wordpress_vpc.id
    cidr_block = var.wordpress_private_subnet_cidr
    availability_zone = var.availability_zone
    tags = {
      Name = "wordpress_private_subnet"
    }
}
resource "aws_subnet" "database_subnet" {
    depends_on = [aws_vpc.wordpress_vpc]
    vpc_id = aws_vpc.wordpress_vpc.id
    cidr_block = var.database_subnet_cidr
    availability_zone = var.availability_zone
    tags = {
      Name = "database_subnet"
    }
}
resource "aws_subnet" "nat_subnet" {
    depends_on = [aws_vpc.wordpress_vpc]
    vpc_id = aws_vpc.wordpress_vpc.id
    cidr_block = var.nat_subnet_cidr
    availability_zone = var.availability_zone
    tags = {
      Name = "nat_subnet"
    }
}
// 3. Network Interface
resource "aws_network_interface" "wordpress_public" {
    depends_on = [aws_vpc.wordpress_vpc, aws_subnet.wordpress_public_subnet, aws_internet_gateway.wordpress_igw, aws_security_group.wordpress_sg]
    subnet_id = aws_subnet.wordpress_public_subnet.id
    security_groups = [aws_security_group.wordpress_sg.id]
    tags = {
      Name = "wordpress_public"
    }
}
resource "aws_network_interface" "wordpress_private" {
    depends_on = [aws_vpc.wordpress_vpc, aws_subnet.wordpress_private_subnet, aws_security_group.wordpress_private_sg]
    subnet_id = aws_subnet.wordpress_private_subnet.id
    security_groups = [aws_security_group.wordpress_private_sg.id]
    tags = {
      Name = "wordpress_private"
    }
}
resource "aws_network_interface" "database_commu" {
    depends_on = [aws_vpc.wordpress_vpc, aws_subnet.wordpress_private_subnet, aws_security_group.database_commu_sg]
    subnet_id = aws_subnet.wordpress_private_subnet.id
    security_groups = [aws_security_group.database_commu_sg.id]
    tags = {
      Name = "database_commu"
    }
}
resource "aws_network_interface" "database" {
    depends_on = [aws_vpc.wordpress_vpc, aws_subnet.database_subnet, aws_security_group.database_sg]
    subnet_id = aws_subnet.database_subnet.id
    security_groups = [aws_security_group.database_sg.id]
    tags = {
      Name = "database"
    }
}