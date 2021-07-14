# Terraform deployment example

## Configuration
Create the following `env.auto.tfvars.json` file from the provided template and populate the required variables:
```bash
cp env.auto.tfvars.json.template env.auto.tfvars.json

vi env.auto.tfvars.json
```

## Setup

Prerequisite:
* `terraform` [CLI](https://www.terraform.io/downloads.html) 
* AWS credentials, either using environment variables or via the CLI and aws configure


```shell
terraform init

terraform apply
```

Use the reported `producer` API GW URL to invoke the lambdas. You may want to use the provided [Node.js client](../client).
