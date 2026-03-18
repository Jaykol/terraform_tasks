resource "aws_security_group" "terra-sg" {
  name        = "terra-sg"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  tags = {
    Name = "terra-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "terra-sg_http" {
  security_group_id = aws_security_group.terra-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ssh-access" {
  security_group_id = aws_security_group.terra-sg.id
  cidr_ipv4         = "${var.ssh_ip}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow-all-outboundipV4" {
  security_group_id = aws_security_group.terra-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow-all-outboundipV6" {
  security_group_id = aws_security_group.terra-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}
