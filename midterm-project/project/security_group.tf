// 4. Security Group
resource "aws_security_group" "wordpress_sg" {
    name        = "wordpress_sg"
    vpc_id      = aws_vpc.wordpress_vpc.id
    depends_on = [ aws_vpc.wordpress_vpc ]
    tags = {
      Name = "wordpress_sg"
    }

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
    depends_on = [ aws_vpc.wordpress_vpc ]

    tags = {
    Name = "database_sg"
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "wordpress_private_sg" {
    name        = "wordpress_private_sg" 
    vpc_id      = aws_vpc.wordpress_vpc.id
    depends_on = [ aws_vpc.wordpress_vpc ]

    tags = {
      Name = "wordpress_private_sg"
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_security_group" "database_commu_sg" {
    name        = "database_commu_sg"
    vpc_id      = aws_vpc.wordpress_vpc.id
    depends_on = [ aws_vpc.wordpress_vpc, aws_security_group.wordpress_private_sg ]

    tags = {
      Name = "database_commu_sg"
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        security_groups = [aws_security_group.wordpress_private_sg.id]
    }

    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        security_groups = [aws_security_group.wordpress_private_sg.id]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [aws_security_group.wordpress_private_sg.id]
    }
}
# // 5. Security Group Rule
# resource "aws_security_group_rule" "wordpress_sg_rule" {
#     depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.wordpress_public_subnet, aws_security_group.wordpress_sg ]
#     type        = "ingress"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = [aws_subnet.wordpress_public_subnet.cidr_block]
#     security_group_id = aws_security_group.wordpress_sg.id
# }
# resource "aws_security_group_rule" "database_sg_rule" {
#     depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.wordpress_private_subnet, aws_security_group.database_sg ]
#     type        = "ingress"
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = [aws_subnet.database_subnet.cidr_block]
#     security_group_id = aws_security_group.database_sg.id
# }

# resource "aws_security_group_rule" "wordpress_private_rule" {
#     depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.wordpress_private_subnet ]
#     type        = "ingress"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [aws_subnet.wordpress_private_subnet.cidr_block]
#     security_group_id = aws_security_group.wordpress_private_sg.id
# }

# resource "aws_security_group_rule" "database_commu_rule" {
#     depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.wordpress_private_subnet, aws_security_group.database_commu_sg ]
#     type        = "ingress"
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     security_group_id = aws_security_group.database_commu_sg.id
#     source_security_group_id = aws_security_group.wordpress_private_sg.id
# }
