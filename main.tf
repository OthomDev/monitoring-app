terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# --- AWS Providers for Multi-Region ---
provider "aws" {
  alias  = "use1"
  region = var.aws_region_use1
}

provider "aws" {
  alias  = "use2"
  region = var.aws_region_use2
}

# --- Fetch Default VPC & Subnets ---
data "aws_vpc" "default_use1" {
  provider = aws.use1
  default  = true
}

data "aws_vpc" "default_use2" {
  provider = aws.use2
  default  = true
}

data "aws_subnets" "default_use1" {
  provider = aws.use1
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_use1.id]
  }
}

data "aws_subnets" "default_use2" {
  provider = aws.use2
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_use2.id]
  }
}

# --- Create Key Pairs ---
resource "aws_key_pair" "flask_key_use1" {
  provider   = aws.use1
  key_name   = "flask_key_use1"
  public_key = file("~/.ssh/my_new_terraform_key.pub")
}

resource "aws_key_pair" "flask_key_use2" {
  provider   = aws.use2
  key_name   = "flask_key_use2"
  public_key = file("~/.ssh/my_new_terraform_key.pub")
}

# --- Security Groups ---
resource "aws_security_group" "flask_sg_use1" {
  provider = aws.use1
  vpc_id   = data.aws_vpc.default_use1.id
  name     = "flask_sg_use1"
  ingress {
    from_port = 4000
    to_port   = 4000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "flask_sg_use2" {
  provider = aws.use2
  vpc_id   = data.aws_vpc.default_use2.id
  name     = "flask_sg_use2"
  ingress {
    from_port = 4000
    to_port   = 4000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Load Balancers ---
resource "aws_lb" "alb_use1" {
  provider            = aws.use1
  name                = "flask-alb-use1"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.flask_sg_use1.id]
  subnets             = data.aws_subnets.default_use1.ids
}

resource "aws_lb" "alb_use2" {
  provider            = aws.use2
  name                = "flask-alb-use2"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.flask_sg_use2.id]
  subnets             = data.aws_subnets.default_use2.ids
}

# --- Target Groups ---
resource "aws_lb_target_group" "tg_use1" {
  provider    = aws.use1
  name        = "tg-use1"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default_use1.id
  target_type = "instance"
}

resource "aws_lb_target_group" "tg_use2" {
  provider    = aws.use2
  name        = "tg-use2"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default_use2.id
  target_type = "instance"
}

# --- EC2 Instances ---
resource "aws_instance" "flask_use1a" {
  provider                = aws.use1
  ami                     = var.ami_id_use1
  instance_type           = var.instance_type
  key_name                = aws_key_pair.flask_key_use1.key_name
  subnet_id               = element(data.aws_subnets.default_use1.ids, 0)
  vpc_security_group_ids  = [aws_security_group.flask_sg_use1.id]
  user_data               = file("${path.module}/userData.sh")
}

resource "aws_instance" "flask_use1b" {
  provider                = aws.use1
  ami                     = var.ami_id_use1
  instance_type           = var.instance_type
  key_name                = aws_key_pair.flask_key_use1.key_name
  subnet_id               = element(data.aws_subnets.default_use1.ids, 1)
  vpc_security_group_ids  = [aws_security_group.flask_sg_use1.id]
  user_data               = file("${path.module}/userData.sh")
}

resource "aws_instance" "flask_use2a" {
  provider                = aws.use2
  ami                     = var.ami_id_use2
  instance_type           = var.instance_type
  key_name                = aws_key_pair.flask_key_use2.key_name
  subnet_id               = element(data.aws_subnets.default_use2.ids, 0)
  vpc_security_group_ids  = [aws_security_group.flask_sg_use2.id]
  user_data               = file("${path.module}/userData.sh")
}

resource "aws_instance" "flask_use2b" {
  provider                = aws.use2
  ami                     = var.ami_id_use2
  instance_type           = var.instance_type
  key_name                = aws_key_pair.flask_key_use2.key_name
  subnet_id               = element(data.aws_subnets.default_use2.ids, 1)
  vpc_security_group_ids  = [aws_security_group.flask_sg_use2.id]
  user_data               = file("${path.module}/userData.sh")
}

# --- Target Group Attachments ---
resource "aws_lb_target_group_attachment" "attach_use1a" {
  provider = aws.use1
  target_group_arn = aws_lb_target_group.tg_use1.arn
  target_id        = aws_instance.flask_use1a.id
  port             = 4000
}

resource "aws_lb_target_group_attachment" "attach_use1b" {
  provider = aws.use1
  target_group_arn = aws_lb_target_group.tg_use1.arn
  target_id        = aws_instance.flask_use1b.id
  port             = 4000
}

resource "aws_lb_target_group_attachment" "attach_use2a" {
  provider = aws.use2
  target_group_arn = aws_lb_target_group.tg_use2.arn
  target_id        = aws_instance.flask_use2a.id
  port             = 4000
}

resource "aws_lb_target_group_attachment" "attach_use2b" {
  provider = aws.use2
  target_group_arn = aws_lb_target_group.tg_use2.arn
  target_id        = aws_instance.flask_use2b.id
  port             = 4000
}


# --- ALB Listeners for Port 4000 ---
resource "aws_lb_listener" "listener_use1" {
  provider          = aws.use1
  load_balancer_arn = aws_lb.alb_use1.arn
  port              = 4000
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_use1.arn
  }
}

resource "aws_lb_listener" "listener_use2" {
  provider          = aws.use2
  load_balancer_arn = aws_lb.alb_use2.arn
  port              = 4000
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_use2.arn
  }
}

