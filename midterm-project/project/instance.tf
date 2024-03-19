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
    echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODaHqtrCOBpfD+meWggDG5gFEqnNDtpxnqQ7xWIfXfL cloud-wordpress' >> ~/.ssh/authorized_keys
    sudo apt update
    sudo apt install apache2 -y
    sudo apt install php8.1 libapache2-mod-php8.1 php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-xmlrpc php8.1-zip php8.1-soap php8.1-intl php8.1-cli php8.1-fpm php8.1-common -y
    sudo systemctl enable php8.1
    sudo systemctl start php8.1
    sudo systemctl restart apache2
    
    wget -c https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    sudo cp -r wordpress/* /var/www/html/
    sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    sudo sed -i "s/database_name_here/${var.database_name}/" /var/www/html/wp-config.php
    sudo sed -i "s/username_here/${var.database_user}/" /var/www/html/wp-config.php
    sudo sed -i "s/password_here/${var.database_pass}/" /var/www/html/wp-config.php
    sudo sed -i "s/localhost/${aws_network_interface.database_commu.private_ip}/" /var/www/html/wp-config.php
    cat <<EOT >> s3_credential.txt

    define( 'AS3CF_SETTINGS', serialize( array (
            'provider' => 'aws',
            'access-key-id' => '${aws_iam_access_key.wordpress_s3_access_key.id}',
            'secret-access-key' => '${aws_iam_access_key.wordpress_s3_access_key.secret}',
            'use-server-roles' => false,
            'bucket' => '${var.bucket_name}',
            'region' => '${var.region}',
            'copy-to-s3' => true,
            'enable-object-prefix' => true,
            'object-prefix' => 'wp-content/uploads/',
            'use-yearmonth-folders' => true,
            'object-versioning' => true,
            'serve-from-s3' => true,

        ) ) );
    EOT
    sed -i "/define( 'WP_DEBUG', false );/r s3_credential.txt" /var/www/html/wp-config.php

    sudo chown -R www-data:www-data /var/www/html
    sudo find /var/www/html -type d -exec chmod 755 {} \;
    sudo find /var/www/html -type f -exec chmod 644 {} \;

    sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    sudo php wp-cli.phar --info
    sudo chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
    cd /var/www/html
    sudo wp core install --url="${aws_eip.wordpress_eip.public_ip}" --admin_user="${var.admin_user}" --admin_password="${var.admin_pass}" --admin_email="exmaple@example.com" --title="Cloud" --skip-email --allow-root
    sudo wp plugin install amazon-s3-and-cloudfront --allow-root --activate

    sudo systemctl restart apache2
    EOF
}

resource "aws_instance" "database_instance" {
    depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.database_subnet, aws_subnet.wordpress_private_subnet, aws_network_interface.database, aws_network_interface.database_commu ]
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
    echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODaHqtrCOBpfD+meWggDG5gFEqnNDtpxnqQ7xWIfXfL cloud-wordpress' >> ~/.ssh/authorized_keys
    sudo apt update -y
    sudo apt install mariadb-server-10.6 -y
    sudo systemctl enable mariadb
    sudo systemctl start mariadb

    sudo mysql -e "CREATE DATABASE ${var.database_name};"
    sudo mysql -e "CREATE USER '${var.database_user}'@'${aws_network_interface.wordpress_private.private_ip}' IDENTIFIED BY '${var.database_pass}';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON ${var.database_name}.* TO "${var.database_user}"@"${aws_network_interface.wordpress_private.private_ip}";"
    sudo mysql -e "FLUSH PRIVILEGES;"

    sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
    sudo systemctl restart mariadb
    EOF
    }
