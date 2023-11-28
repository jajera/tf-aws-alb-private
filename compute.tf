# get image ami
data "aws_ami" "example" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# create vm
resource "aws_instance" "public1" {
  ami                  = data.aws_ami.example.image_id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm.name
  subnet_id            = aws_subnet.public1.id
  vpc_security_group_ids = [
    aws_security_group.http_ec2.id
  ]
  associate_public_ip_address = true

  user_data = filebase64("${path.module}/external/web.conf")

  depends_on = [
    aws_nat_gateway.example
  ]

  tags = {
    Name    = "tf-instance-example-public1"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_instance" "private1" {
  ami                  = data.aws_ami.example.image_id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm.name
  subnet_id            = aws_subnet.private1.id
  vpc_security_group_ids = [
    aws_security_group.http_ec2.id
  ]
  associate_public_ip_address = false

  user_data = filebase64("${path.module}/external/web.conf")

  depends_on = [
    aws_nat_gateway.example
  ]

  tags = {
    Name    = "tf-instance-example-private1"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_instance" "public2" {
  ami                  = data.aws_ami.example.image_id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm.name
  subnet_id            = aws_subnet.public2.id
  vpc_security_group_ids = [
    aws_security_group.http_ec2.id
  ]
  associate_public_ip_address = true

  user_data = filebase64("${path.module}/external/web.conf")

  depends_on = [
    aws_nat_gateway.example
  ]

  tags = {
    Name    = "tf-instance-example-public2"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}

resource "aws_instance" "private2" {
  ami                  = data.aws_ami.example.image_id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm.name
  subnet_id            = aws_subnet.private2.id
  vpc_security_group_ids = [
    aws_security_group.http_ec2.id
  ]
  associate_public_ip_address = false

  user_data = filebase64("${path.module}/external/web.conf")

  depends_on = [
    aws_nat_gateway.example
  ]

  tags = {
    Name    = "tf-instance-example-private2"
    Owner   = "John Ajera"
    UseCase = var.use_case
  }
}
