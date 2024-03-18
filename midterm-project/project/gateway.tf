// 7. Internet Gateway
resource "aws_internet_gateway" "wordpress_igw" {
    vpc_id = aws_vpc.wordpress_vpc.id
}

// 8. NAT Gateway
resource "aws_nat_gateway" "wordpress_nat_gw" {
    depends_on = [ aws_eip.nat_eip, aws_subnet.nat_subnet ]
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.nat_subnet.id
    lifecycle {
        create_before_destroy = true
    }
}

// 12. Elastic IP
resource "aws_eip" "wordpress_eip" {
    depends_on = [ aws_network_interface.wordpress_public ]
    network_interface = aws_network_interface.wordpress_public.id
}

resource "aws_eip" "nat_eip" {

}

// 13. Elastic IP Association
resource "aws_eip_association" "wordpress_eip_assoc" {
    depends_on = [ aws_eip.wordpress_eip ]
    network_interface_id = aws_network_interface.wordpress_public.id
    allocation_id = aws_eip.wordpress_eip.id
}

resource "aws_eip_association" "nat_eip_assoc" {
    depends_on = [ aws_eip.nat_eip, aws_nat_gateway.wordpress_nat_gw ]
    network_interface_id = aws_network_interface.database.id
    allocation_id = aws_eip.nat_eip.id
}