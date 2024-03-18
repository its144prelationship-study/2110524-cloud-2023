// 6. Instance
resource "aws_instance" "wordpress_instance" {
    depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.wordpress_public_subnet, aws_network_interface.wordpress_public, aws_network_interface.wordpress_private ]
    ami           = var.ami
    instance_type = var.instance_type
    network_interface {
        network_interface_id = aws_network_interface.wordpress_public.id
        device_index = 0
    }
    network_interface {
        network_interface_id = aws_network_interface.wordpress_private.id
        device_index = 1
    }

    user_data = file("./scripts/wordpress.sh")
    # provisioner "local-exec" {
    #   command = "./scripts/provisioner.sh"
    # }
}

resource "aws_instance" "database_instance" {
    depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.database_subnet, aws_subnet.wordpress_private_subnet, aws_instance.wordpress_instance, aws_network_interface.database, aws_network_interface.database_commu]
    ami           = var.ami
    instance_type = var.instance_type
    network_interface {
        network_interface_id = aws_network_interface.database.id
        device_index = 0
    }
    network_interface {
        network_interface_id = aws_network_interface.database_commu.id
        device_index = 1
    }

    user_data = file("./scripts/mariadb.sh")
}