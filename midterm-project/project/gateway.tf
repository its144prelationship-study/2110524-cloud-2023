// 7. Internet Gateway
resource "aws_internet_gateway" "wordpress_igw" {
    vpc_id = aws_vpc.wordpress_vpc.id
}

// 8. NAT Gateway
resource "aws_nat_gateway" "wordpress_nat_gw" {
    depends_on = [ aws_eip.nat_eip, aws_subnet.nat_subnet ]
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.nat_subnet.id
}

// 12. Elastic IP
resource "aws_eip" "wordpress_eip" {
    depends_on = [ aws_network_interface.wordpress_public, aws_instance.wordpress_instance ]
    network_interface = aws_network_interface.wordpress_public.id
    associate_with_private_ip = aws_network_interface.wordpress_public.private_ip
}

resource "aws_eip" "nat_eip" {
}