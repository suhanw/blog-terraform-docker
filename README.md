### Building and running your application

`docker compose up --build`

### Run an existing Docker image

`docker run --publish 3000:3000 blog-terraform-docker-server`

### Terraform

Include AWS credentials in `.env`. Run `source .env` before `terraform apply`.
