resource "aws_security_group" "web_sg" {
	name = "${var.environment}-web-sg"
	vpc_id = var.vpc_id
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
    cidr_blocks = ["0.0.0.0/0"]
  }
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

}


resource "aws_instance" "web-app"{
	ami = var.ami_id
	instance_type = var.instance_type
	subnet_id = var.private_subnet_id
	vpc_security_group_ids= [aws_security_group.web_sg.id]
	tags = { Name = "${var.environment}-web-server" }
  key_name = var.key_name
}

resource "aws_lb" "web_alb" {
  name = "${var.environment}-web-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.web_sg.id]
  subnets = var.public_subnet_ids
}

resource "aws_lb_target_group" "web_tg" {
  name = "${var.environment}-web-target-group"
  port = "80"
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    path = "/"
    port = "80"
    protocol = "HTTP"
    unhealthy_threshold = 3
    healthy_threshold = 3
  }

}

resource "aws_lb_target_group_attachment" "web_tg_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id = aws_instance.web-app.id
  port = "80"

}

resource "aws_lb_listener" "web_alb_listener"{
  load_balancer_arn = aws_lb.web_alb.id
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

}
