
# load balancer security group
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow http from internet(route53)"
  vpc_id      = local.vpc_id

  ingress {
    description = "http from internet(route53)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https from internet(route53)"
    from_port   = 443
    to_port     = 443
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
    Name = "alb_sg"
  }
}

# front end app security group
resource "aws_security_group" "fronend_app" {
  name        = "fronend_app"
  description = "Allow http from loadbalancer"
  vpc_id      = local.vpc_id

  ingress {
    description     = "http from loadbalancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
    description     = "https from loadbalancer"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fronend_app"
  }
}

# Refistration app security group.. 
resource "aws_security_group" "registration_app_sg" {
  name        = "registration_app_sg"
  description = "Allow 8080 from loadbalancer"
  vpc_id      = local.vpc_id

  ingress {
    description     = "Allow 8080 from loadbalancer"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "registration_app_sg"
  }
}

# Database security group. 
resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Allow traffic from registration_app"
  vpc_id      = local.vpc_id

  ingress {
    description     = "Allow 8080 from loadbalancer"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.registration_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database_sg"
  }
}