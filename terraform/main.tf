resource "aws_vpc" "soul" {
    cidr_block = "192.168.1.0/24"
}

resource "aws_subnet" "society" {
    vpc_id = aws_vpc.soul.id
    cidr_block = "192.168.1.0/28"
    map_public_ip_on_launch = true
    tags = {
        Name = "Society_PUBLIC"
    }
}

resource "aws_internet_gateway" "igw_salida" {
    vpc_id = aws_vpc.soul.id
    tags = {
        Name = "igw_salida"
    }
}

resource "aws_route_table" "RT_internet" {
   vpc_id = aws_vpc.soul.id

   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_salida.id
   } 
}

resource "aws_route_table_association" "asigRT_internet" {
  subnet_id      = aws_subnet.society.id
  route_table_id = aws_route_table.RT_internet.id
}

resource "aws_security_group" "sg_allow_http" {
    name = "Allow HTTP"
    description = "Allow inbound http traffic"
    vpc_id = aws_vpc.soul.id
    ingress {
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
        Name = "allow_http"
    }
}

resource "aws_key_pair" "parClaves" {
    key_name = "parClaves"
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8fsk51rJMm7spbqBzLrQsnCglZaBWrNTKfr8/7Ay4X elixs@NAVE"
}

resource "aws_instance" "servidor_web" {
    ami = "ami-07ff62358b87c7116" #La imagen id es dependiendo de la region, cada region tiene sus ID's
    instance_type = "t2.micro"
    subnet_id = aws_subnet.society.id
    vpc_security_group_ids = [aws_security_group.sg_allow_http.id]
    key_name = aws_key_pair.parClaves.key_name
    user_data = <<EOF
#!/bin/bash
dnf update -y
dnf install nginx -y
echo "Hola desde AWS – desplegado automáticamente" > /usr/share/nginx/html/index.html
systemctl enable nginx
systemctl start nginx
EOF
    tags = {
        Name = "Servidor Nginx" #Nombre de la instancia EC2
    } 
}

