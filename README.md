# AWS [Elastic Container Service Fargate](https://aws.amazon.com/fargate/) with [Terraform](https://www.terraform.io/)

Init:

```sh
cd terraform
terraform init
```

Use `Elastic Container Registry` to store docker image:

```sh
terraform apply --target aws_ecr_repository.app
```

Login to `Elastic Container Repository`:

```sh
$(aws ecr get-login --region $(terraform output aws_region) --no-include-email)
```

Build and publish docker:

```sh
docker build -t app ..
docker tag app $(terraform output app-repo):latest
docker push $(terraform output app-repo):latest
```

Review:

```sh
terraform plan
```

Deploy:

```sh
terraform apply
```

Test:

```sh
curl $(terraform output alb_dns_name)
```

Destroy:

```sh
terraform destroy
```