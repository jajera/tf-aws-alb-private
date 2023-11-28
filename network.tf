resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "tf-vpc-example"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"

  tags = {
    Name    = "tf-subnet-public1"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"

  tags = {
    Name    = "tf-subnet-private1"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1b"

  tags = {
    Name    = "tf-subnet-public2"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1b"

  tags = {
    Name    = "tf-subnet-private2"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name    = "tf-ig-example"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
  }

  tags = {
    Name    = "tf-rt-private1"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
  }

  tags = {
    Name    = "tf-rt-private2"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_route_table" "public1" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name    = "tf-rt-public"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public1.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public1.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private2.id
}

resource "aws_eip" "example" {
  domain = "vpc"

  tags = {
    Name    = "tf-eip-example"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.example.id
  subnet_id     = aws_subnet.public1.id

  depends_on = [
    aws_internet_gateway.example
  ]

  tags = {
    Name    = "tf-ngw-example"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_lb_target_group" "example" {
  name        = "example"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.example.id

  health_check {
    enabled             = true
    healthy_threshold   = 5
    unhealthy_threshold = 2
    path                = "/"
  }

  tags = {
    Name  = "tf-alb-tg-example"
    Owner = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_lb_target_group_attachment" "public1" {
  target_group_arn = aws_lb_target_group.example.arn
  target_id        = aws_instance.public1.id
}

resource "aws_lb_target_group_attachment" "private1" {
  target_group_arn = aws_lb_target_group.example.arn
  target_id        = aws_instance.private1.id
}

resource "aws_lb_target_group_attachment" "public2" {
  target_group_arn = aws_lb_target_group.example.arn
  target_id        = aws_instance.public2.id
}

resource "aws_lb_target_group_attachment" "private2" {
  target_group_arn = aws_lb_target_group.example.arn
  target_id        = aws_instance.private2.id
}

resource "aws_security_group" "http_alb" {
  name        = "tf-sg-example-http_alb"
  description = "Security group for example resources to allow alb access to http"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "tf-sg-example_http_alb"
    Owner = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_security_group" "http_ec2" {
  name        = "tf-sg-example-http_ec2"
  description = "Security group for example resources to allow access to http hosted in ec2"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.http_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "tf-sg-example_http_ec2"
    Owner = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_lb" "example" {
  name                       = "example"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = false
  drop_invalid_header_fields = true
  idle_timeout               = 600

  security_groups = [
    aws_security_group.http_alb.id
  ]

  subnets = [
    aws_subnet.public1.id,
    aws_subnet.public2.id,
  ]

  tags = {
    Name  = "tf-alb-example"
    Owner = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }

  tags = {
    Name  = "tf-alb-listener-example"
    Owner = "John Ajera"
    UseCase = var.use_case
  }
}
