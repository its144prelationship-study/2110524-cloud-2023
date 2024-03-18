# "wp core install --url="${aws_eip.wordpress_ip.public_ip}" "
# "--admin_user="${var.admin_user}" "
# "--admin_password="${var.admin_pass}""
# "--admin_email="exmaple@example.com" --title="Cloud" --skip-email"

#!/bin/bash

wp core install \
    --url="${aws_eip.wordpress_ip.public_ip}" \
    --admin_user="${var.admin_user}" \
    --admin_password="${var.admin_pass}" \
    --admin_email="example@example.com" \
    --title="Cloud" \
    --skip-email