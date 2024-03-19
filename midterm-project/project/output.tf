output "public_ip" {
    depends_on = [ aws_instance.wordpress_instance ]
    value = {
        eip = aws_eip.wordpress_eip.public_ip
        path = "${aws_eip.wordpress_eip.public_ip}/index.php"
    }
}