resource "aws_ecs_cluster" "fargate" {
  name = "${var.NAME}"
}

data "template_file" "app" {
  template = "${file("templates/ecs/app.json.tpl")}"
  vars {
    AWS_REGION = "${var.AWS_REGION}"
    NAME = "${var.NAME}"
    PORT = "${var.PORT}"
    REPOSITORY_URL = "${aws_ecr_repository.app.repository_url}"
    LOGS_GROUP = "${aws_cloudwatch_log_group.app.name}"
  }
}

resource "aws_ecs_task_definition" "app" {
  family = "${var.NAME}"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "${var.CPU}"
  memory = "${var.MEMORY}"
  container_definitions = "${data.template_file.app.rendered}"
  execution_role_arn = "${aws_iam_role.ecs_task_assume.arn}"
}

resource "aws_ecs_service" "app" {
  name            = "${var.NAME}"
  cluster         = "${aws_ecs_cluster.fargate.id}"
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count   = 1

  network_configuration = {
    subnets = ["${module.base_vpc.private_subnets[0]}", "${module.base_vpc.private_subnets[1]}"]
    security_groups = ["${aws_security_group.ecs.id}"]
  }

  load_balancer {
   target_group_arn = "${aws_alb_target_group.app.arn}"
   container_name = "${var.NAME}"
   container_port = "${var.PORT}"
  }

  depends_on = [
    "aws_alb_listener.app"
  ]
}

resource "aws_security_group" "ecs" {
  name        = "${var.NAME}-ecs"
  description = "Allow traffic for ecs"
  vpc_id      = "${module.base_vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${split(",", var.CIDR_PUBLIC)}"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${split(",", var.CIDR_PRIVATE)}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_iam_role" "ecs_task_assume" {
  name = "${var.NAME}-ecs_task_assume"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_task_assume" {
  name = "${var.NAME}-ecs_task_assume"
  role = "${aws_iam_role.ecs_task_assume.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_cloudwatch_log_group" "app" {
  name = "/${var.NAME}"
  retention_in_days = 30
}