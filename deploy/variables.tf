variable "function_name" {
  type        = string
  description = "Name of sample app function / API gateway"
  default     = "adot-python-lambdas"
}

variable "elastic_otlp_endpoint" {
  type        = string
  description = "Elastic OTLP endpoint (e.g. 'apm-server.elastic.mycompany.com:443')"
}

variable "elastic_otlp_token" {
  type        = string
  sensitive   = true
  description = "Elastic OTLP token (aka Elastic APM Server Token)"
}

variable "aws_region" {
  type        = string
  description = "AWS Region to deploy the app"
}