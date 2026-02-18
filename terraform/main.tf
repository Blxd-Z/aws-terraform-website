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

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
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

resource "aws_s3_bucket" "website" {
  bucket = "website-portfolio-ilyass"
  tags = {
    Name = "Backend for terraform"
  }
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.website.id
  key    = "index.html"
  source = "../frontend/index.html"
  content_type = "text/html"
  etag = filemd5("../frontend/index.html")
}

resource "aws_s3_object" "styles_css" {
  bucket = aws_s3_bucket.website.id
  key    = "styles.css"
  source = "../frontend/styles.css"
  content_type = "text/css"
}

resource "aws_s3_object" "app_js" {
  bucket = aws_s3_bucket.website.id
  key    = "app.js"
  source = "../frontend/app.js"
  content_type = "application/javascript"
}

resource "aws_s3_object" "curriculum_pdf" {
  bucket = aws_s3_bucket.website.id
  key = "cv.pdf"
  source = "../frontend/cv.pdf"
  content_type = "application/pdf"
  etag  = filemd5("../frontend/cv.pdf")
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "s3-portfolio-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = "S3-${aws_s3_bucket.website.bucket}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website.bucket}"

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    viewer_protocol_policy = "redirect-to-https" # ¡HTTPS forzado!
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
resource "aws_s3_bucket_policy" "cdn_policy" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        # Importante: El /* al final para que pueda leer todos los archivos
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}
resource "aws_instance" "servidor_web" {
    ami = "ami-07ff62358b87c7116" #La imagen id es dependiendo de la region, cada region tiene sus ID's
    instance_type = "t2.micro"
    subnet_id = aws_subnet.society.id
    vpc_security_group_ids = [aws_security_group.sg_allow_http.id]
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



















