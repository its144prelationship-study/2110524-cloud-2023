// 6. Instance
resource "aws_instance" "wordpress_instance" {
    depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.wordpress_public_subnet, aws_subnet.wordpress_private_subnet, aws_security_group.wordpress_sg ]
    ami           = var.ami
    instance_type = var.instance_type
    for_each = {
        for idx, subnet_id in [aws_subnet.wordpress_public_subnet.id, aws_subnet.wordpress_private_subnet.id] :
        idx => subnet_id
    }

    subnet_id = each.value
        tags = {
            Name = var.wordpress_instance
        }
    security_groups = [aws_security_group.wordpress_sg.id]

    user_data = file("./scripts/wordpress.sh")
}

resource "aws_instance" "database_instance" {
    depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.database_subnet, aws_subnet.wordpress_private_subnet, aws_security_group.database_sg, aws_instance.wordpress_instance ]
    ami           = var.ami
    instance_type = var.instance_type
    for_each = {
        for idx, subnet_id in [aws_subnet.database_subnet.id, aws_subnet.wordpress_private_subnet.id] :
        idx => subnet_id
    }

    subnet_id = each.value
        tags = {
            Name = var.database_instance
        }
    security_groups = [aws_security_group.database_sg.id]

    user_data = file("./scripts/mariadb.sh")
}