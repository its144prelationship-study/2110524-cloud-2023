// 4. Security Group
resource "aws_security_group" "wordpress_sg" {
    name        = "wordpress_sg"
    vpc_id      = aws_vpc.wordpress_vpc.id
    depends_on = [ aws_vpc.wordpress_vpc ]

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "database_sg" {
    name        = "database_sg"
    vpc_id      = aws_vpc.wordpress_vpc.id
    depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.wordpress_public_subnet, aws_subnet.wordpress_private_subnet, aws_security_group.wordpress_sg, aws_instance.wordpress_instance ]

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    dynamic "ingress" {
        for_each = aws_instance.wordpress_instance
        content {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = [format("%s/32", ingress.value.private_ip)]
        }
    }
    dynamic "ingress" {
        for_each = aws_instance.wordpress_instance
        content {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [format("%s/32", ingress.value.private_ip)]
        }
    }
}

resource "aws_security_group" "instance_commu" {
    name        = "instance_commu"
    vpc_id      = aws_vpc.wordpress_vpc.id
    depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.database_subnet, aws_subnet.wordpress_private_subnet, aws_security_group.wordpress_sg, aws_security_group.database_sg, aws_instance.wordpress_instance, aws_instance.database_instance ]

    dynamic "ingress" {
        for_each = aws_instance.wordpress_instance
        content {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [format("%s/32", ingress.value.private_ip)]
        }
    }
    dynamic "ingress" {
        for_each = aws_instance.database_instance
        content {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [format("%s/32", ingress.value.private_ip)]
        }
    }
}
// 5. Security Group Rule
resource "aws_security_group_rule" "wordpress_sg_rule" {
    depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.wordpress_public_subnet, aws_security_group.wordpress_sg ]
    type        = "ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.wordpress_public_subnet.cidr_block]
    security_group_id = aws_security_group.wordpress_sg.id
}
resource "aws_security_group_rule" "database_sg_rule" {
    depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.wordpress_private_subnet, aws_security_group.database_sg, aws_instance.wordpress_instance ]
    type        = "ingress"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.database_subnet.cidr_block]
    security_group_id = aws_security_group.database_sg.id
}

resource "aws_security_group_rule" "instance_commu_rule" {
    depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.wordpress_private_subnet, aws_security_group.instance_commu, aws_instance.wordpress_instance, aws_instance.database_instance ]
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.wordpress_private_subnet.cidr_block]
    security_group_id = aws_security_group.instance_commu.id
}