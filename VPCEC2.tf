provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_vpc" "DataCent" {
  cidr_block = "11.0.0.0/16"
  tags = {
    "Name" = "Lab_DataCenter"
  } 
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.DataCent.id
  tags = {
    "Name" = "Lab_igw"
  }
}

resource "aws_route_table" "rtable" {
  vpc_id = aws_vpc.DataCent.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
route {
  ipv6_cidr_block = "::/0"
  gateway_id = aws_internet_gateway.igw.id
}

tags = {
  "Name" = "LabRoute"
}
}

resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.DataCent.id
  cidr_block = "11.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "Lab_Sub"
  }
}
resource "aws_route_table_association" "asso"{
  subnet_id = aws_subnet.sub1.id
  route_table_id = aws_route_table.rtable.id
}

resource "aws_security_group" "secgroup" {
  name = "Security_Group"
  description = "its all about security"
  vpc_id = aws_vpc.DataCent.id

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
tags = {
  "Name" = "LabSecurity"
}
}

resource "aws_network_interface" "netinter" {
  subnet_id = aws_subnet.sub1.id
  private_ip = "11.0.1.100"
  security_groups = [aws_security_group.secgroup.id]
}

resource "aws_eip" "elasticadd" {
  vpc = true
#   network_interface = aws_network_interface.netinter.id
#   associate_with_private_ip = "11.0.0.10"
#   depends_on = [aws_internet_gateway.igw]
}

resource "aws_instance" "Mail"{
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "class"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.netinter.id
  }

  # user_data = <<-EOF
  #               #!/bin/bash
  #               sudo apt update -y
  #               sudo apt install apache2 -y
  #               sudo systemctl start apache2
  #               sudo bash -c 'echo your Hello Friend > /var/www/html/index.html'
  #               EOF
tags = {
 Name : "LabServer"
}
}
