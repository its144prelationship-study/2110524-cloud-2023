// 10. Route Table
resource "aws_route_table" "public_route_table" {
  depends_on = [ aws_vpc.wordpress_vpc ]
  vpc_id = aws_vpc.wordpress_vpc.id
}
resource "aws_route_table" "private_route_table" {
  depends_on = [ aws_vpc.wordpress_vpc ]
  vpc_id = aws_vpc.wordpress_vpc.id
}

resource "aws_route_table" "gateway_route_table" {
  depends_on = [ aws_vpc.wordpress_vpc ]
  vpc_id = aws_vpc.wordpress_vpc.id
}
// 9. Route
resource "aws_route" "public_route" {
  depends_on = [ aws_vpc.wordpress_vpc, aws_internet_gateway.wordpress_igw, aws_subnet.wordpress_public_subnet, aws_route_table.public_route_table]
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.wordpress_igw.id
}
resource "aws_route" "private_route" {
  depends_on = [ aws_vpc.wordpress_vpc, aws_nat_gateway.wordpress_nat_gw, aws_subnet.database_subnet, aws_route_table.private_route_table]
  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = aws_subnet.database_subnet.cidr_block
  gateway_id = aws_nat_gateway.wordpress_nat_gw.id
}
resource "aws_route" "gateway_route" {
  depends_on = [ aws_vpc.wordpress_vpc, aws_internet_gateway.wordpress_igw, aws_route_table.gateway_route_table]
  route_table_id = aws_route_table.gateway_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.wordpress_igw.id
}
// 11. Route Table Association
resource "aws_route_table_association" "public_route_table_assoc" {
  depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.wordpress_public_subnet, aws_route_table.public_route_table]
  subnet_id = aws_subnet.wordpress_public_subnet.id
  route_table_id = aws_route_table.public_route_table.id

}
resource "aws_route_table_association" "private_route_table_assoc" {
  depends_on = [ aws_vpc.wordpress_vpc, aws_subnet.wordpress_private_subnet, aws_route_table.private_route_table]
  subnet_id = aws_subnet.database_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}