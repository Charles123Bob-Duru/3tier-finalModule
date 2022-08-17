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


resource "aws_security_group" "http" {
  name        = "http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.kojitechs_vpc.id

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "http"
  }
}

resource "aws_instance" "front_end" {

    ami = data.aws_ami.ami.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public_subnet[0].id
    vpc_security_group_ids = [aws_security_group.http.id]
    user_data = file("${path.module}/template/frontend.sh")
    iam_instance_profile = aws_iam_instance_profile.instance_profile.name

    tags = {
        Name = "front_end"
    }
}