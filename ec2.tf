data "aws_ami" "ami" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app1" {

  ami                    = data.aws_ami.ami.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet[0].id # private subnet
  vpc_security_group_ids = [aws_security_group.fronend_app.id]
  user_data              = file("${path.module}/template/app1.sh") # bootstrapping...
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name = "frontend_app1"
  }
}

resource "aws_instance" "app2" {

  ami                    = data.aws_ami.ami.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet[1].id # private subnet
  vpc_security_group_ids = [aws_security_group.fronend_app.id]
  user_data              = file("${path.module}/template/app2.sh")
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name = "frontend_app2"
  }
}