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

    user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install apache2 -y
    sudo apt install php8.1 libapache2-mod-php8.1 php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-xmlrpc php8.1-zip php8.1-soap php8.1-intl php8.1-cli php8.1-fpm php8.1-common -y

    wget -c https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    cp -r wordpress/* /var/www/html/
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    sed -i "s/database_name_here/wordpress_db/" /var/www/html/wp-config.php
    sed -i "s/username_here/${var.database_user}/" /var/www/html/wp-config.php
    sed -i "s/password_here/${var.database_pass}/" /var/www/html/wp-config.php

    sudo chown -R www-data:www-data /var/www/html
    sudo systemctl restart apache2
    EOF
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
        user_data = <<-EOF
        #!/bin/bash
        sudo apt update
        sudo apt install mariadb-server -y

        sudo mysql_secure_installation <<EOFSECURE
        ${var.database_pass}
        ${var.database_pass}
        n
        n
        n
        n
        EOFSECURE

        sudo mysql -u root -p"${var.database_pass}" <<EOFMYSQL
        CREATE DATABASE wordpress_db;
        CREATE USER 'wordpress-user'@'${aws_instance.wordpress_instance.private_ip}' IDENTIFIED BY '${var.database_pass}';
        GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress-user'@'${aws_instance.wordpress_instance.private_ip}';
        FLUSH PRIVILEGES;
        EOFMYSQL
        EOF
    }
