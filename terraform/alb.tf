resource "aws_alb" "app" {
  name = "${var.NAME}"
  internal = false

  security_groups = [
    "${aws_security_group.ecs.id}",
    "${aws_security_group.alb.id}",
  ]

  subnets = [
    "${module.base_vpc.public_subnets[0]}",
    "${module.base_vpc.public_subnets[1]}"
  ]
}

resource "aws_alb_target_group" "app" {
  name = "${var.NAME}"
  protocol = "HTTP"
  port = "3000"
  vpc_id = "${module.base_vpc.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_alb_listener" "app" {
  load_balancer_arn = "${aws_alb.app.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.app.arn}"
    type = "forward"
  }

  depends_on = ["aws_alb_target_group.app"]
}

resource "aws_security_group" "alb" {
  name        = "${var.NAME}-alb"
  description = "Allow traffic for alb"
  vpc_id      = "${module.base_vpc.vpc_id}"

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
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

output "alb_dns_name" {
  value = "${aws_alb.app.dns_name}"
}
