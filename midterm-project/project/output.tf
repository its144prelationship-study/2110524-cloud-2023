output "public_ip" {
    depends_on = [ aws_instance.wordpress_instance ]
    value = {
        public_ip = aws_instance.wordpress_instance.public_ip
    }
}