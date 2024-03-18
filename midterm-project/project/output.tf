# output "eip" {
#     depends_on = [ aws_eip.wordpress_eip ]
#     value = {
#         wordpress_eip = aws_eip.wordpress_eip.public_ip
#     }
# }