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


data "aws_secretsmanager_secret_version" "secret-version" {
  secret_id = "hqr-common-database-Writer-endpoint-default20220824020209256500000002"
}

# app1
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

# app2
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

# Registration app
resource "aws_instance" "registration_app" {
  count = length(var.tag_name)
  depends_on = [module.aurora]

  ami                    = data.aws_ami.ami.id
  instance_type          = "t2.xlarge"
  subnet_id              = element(slice(aws_subnet.private_subnet[*].id, 0, 2), count.index) # ensure infra stability...
  vpc_security_group_ids = [aws_security_group.registration_app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  user_data = templatefile("${path.module}/template/registration_app.tmpl",
    {
      endpoint    = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["endpoint"]
      port        = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["port"]
      db_name     = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["dbname"]
      db_user     = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["username"]
      db_password = jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["password"]
    }
  )

  tags = {
    Name = var.tag_name[count.index]
  }
}
