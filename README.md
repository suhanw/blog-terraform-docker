## Docker notes

ECR repo: `026424947954.dkr.ecr.us-east-1.amazonaws.com/blog-terraform-docker`

### Building and running your application

```
docker compose up --build
```

### Build an image

```
docker build . -t 026424947954.dkr.ecr.us-east-1.amazonaws.com/blog-terraform-docker:latest
```

### Run an existing image

```
docker images
```

```
docker run --publish 3000:3000 {image_repo}
```

### Pushing the latest image to ECR

[Authenticate with IAM user credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html#cli-authentication-user-configure-wizard)

```
aws configure --profile blog-terraform-docker
```

Check `~/.aws/config`.

[Pushing a Docker image](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html).

```
aws ecr get-login-password --profile blog-terraform-docker --region us-east-1 | docker login --username AWS --password-stdin 026424947954.dkr.ecr.us-east-1.amazonaws.com
```

```
docker push 026424947954.dkr.ecr.us-east-1.amazonaws.com/blog-terraform-docker:latest
```

## Terraform notes

Include IAM user credentials in `.env`. Run `source .env` before `terraform apply`.
