// 6. Instance
resource "aws_instance" "wordpress_instance" {
    depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.wordpress_public_subnet, aws_network_interface.wordpress_public, aws_network_interface.wordpress_private, aws_instance.database_instance ]
    ami           = var.ami
    instance_type = var.instance_type

    tags = {
      Name = "wordpress_instance"
    }
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
    sudo systemctl enable php8.1-fpm
    sudo systemctl start php8.1-fpm
    sudo systemctl restart apache2
    
    wget -c https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    sudo cp -r wordpress/* /var/www/html/
    sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    sudo sed -i "s/database_name_here/${var.database_name}/" /var/www/html/wp-config.php
    sudo sed -i "s/username_here/${var.database_user}/" /var/www/html/wp-config.php
    sudo sed -i "s/password_here/${var.database_pass}/" /var/www/html/wp-config.php
    sudo sed -i "s/localhost/${aws_instance.database_instance.private_ip}/" /var/www/html/wp-config.php

    sudo chown -R www-data:www-data /var/www/html
    sudo find /var/www/html -type d -exec chmod 755 {} \;
    sudo find /var/www/html -type f -exec chmod 644 {} \;
    sudo systemctl restart apache2
    EOF
}

resource "aws_instance" "database_instance" {
    depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.database_subnet, aws_subnet.wordpress_private_subnet, aws_network_interface.database, aws_network_interface.database_commu, aws_eip.wordpress_eip]
    ami           = var.ami
    instance_type = var.instance_type
    tags = {
      Name = "database_instance"
    }
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
        sudo apt install -y mariadb-server
        sudo systemctl enable mariadb
        sudo systemctl start mariadb

        sudo mysql_secure_installation <<EOFSECURE
        ${var.database_pass}
        n
        n
        n
        n
        n
        n
        EOFSECURE

        sudo mysql -u root -p"${var.database_pass}" <<EOFMYSQL
        CREATE DATABASE ${var.database_name};
        CREATE USER '${var.database_user}'@'%' IDENTIFIED BY '${var.database_pass}';
        GRANT ALL PRIVILEGES ON `${var.database_name}`.* TO '${var.database_user}'@'%';
        FLUSH PRIVILEGES;
        exit
        EOFMYSQL
        sudo systemctl restart mariadb
        EOF
    }
