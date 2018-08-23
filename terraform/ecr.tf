resource "aws_ecr_repository" "app" {
  name = "${var.NAME}"
}

output "app-repo" {
  value = "${aws_ecr_repository.app.repository_url}"
}
