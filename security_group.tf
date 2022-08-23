
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