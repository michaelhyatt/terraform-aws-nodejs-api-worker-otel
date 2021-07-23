provider "aws" {
  region = var.aws_region
}

module "nodejs-producer-lambda-function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = format("%s-producer", var.function_name)
  handler       = "handler.producer"
  runtime       = "nodejs14.x"

  create_package         = true

  source_path = "../src"

  timeout = 30

  layers = compact([
    lookup(local.sdk_layer_arns, var.aws_region, "invalid")
  ])

  environment_variables = {
    AWS_LAMBDA_EXEC_WRAPPER: "/opt/otel-handler"
    ELASTIC_OTLP_ENDPOINT: var.elastic_otlp_endpoint
    ELASTIC_OTLP_TOKEN: var.elastic_otlp_token
    OPENTELEMETRY_COLLECTOR_CONFIG_FILE: "/var/task/opentelemetry-collector.yaml"
    OTEL_PROPAGATORS: "tracecontext"

    # Required setting until this https://github.com/open-telemetry/opentelemetry-js/pull/2331 is merged and released.
    OTEL_EXPORTER_OTLP_ENDPOINT: "http://localhost:55681/v1/traces"

    # Turn on sampling, if not sent from the caller. This can potentially create a very large amount of data.
    OTEL_TRACES_SAMPLER: "AlwaysOn"    
  }

  tracing_mode = "PassThrough" // ensure xray doesn't modify the trace context. See "api-gateway" enable_xray_tracing below

}

module "nodejs-consumer-lambda-function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = format("%s-consumer", var.function_name)
  handler       = "handler.consumer"
  runtime       = "nodejs14.x"

  create_package         = true

  timeout = 20

  source_path = "../src"

  layers = compact([
    lookup(local.sdk_layer_arns, var.aws_region, "invalid")
  ])

  environment_variables = {
    AWS_LAMBDA_EXEC_WRAPPER: "/opt/otel-handler"
    ELASTIC_OTLP_ENDPOINT: var.elastic_otlp_endpoint
    ELASTIC_OTLP_TOKEN: var.elastic_otlp_token
    OPENTELEMETRY_COLLECTOR_CONFIG_FILE: "/var/task/opentelemetry-collector.yaml"
    OTEL_PROPAGATORS: "tracecontext"
    CONSUMER_API: module.producer-api-gateway.api_gateway_url

    # Required setting until this https://github.com/open-telemetry/opentelemetry-js/pull/2331 is merged and released.
    OTEL_EXPORTER_OTLP_ENDPOINT: "http://localhost:55681/v1/traces"    

    # Turn on sampling, if not sent from the caller. This can potentially create a very large amount of data.
    OTEL_TRACES_SAMPLER: "AlwaysOn"
  }

  tracing_mode = "PassThrough" // ensure xray doesn't modify the trace context. See "api-gateway" enable_xray_tracing below

}

module "consumer-api-gateway" {
  source = "../utils/terraform/api-gateway-proxy"

  name                = format("%s-APIGW", var.function_name)
  function_name       = module.nodejs-consumer-lambda-function.lambda_function_name
  function_invoke_arn = module.nodejs-consumer-lambda-function.lambda_function_invoke_arn
  enable_xray_tracing = false // ensure xray doesn't modify the trace context. See AWS Lambda Function attribute `tracing_mode` above

}

module "producer-api-gateway" {
  source = "../utils/terraform/api-gateway-proxy"

  name                = format("%s-APIGW", var.function_name)
  function_name       = module.nodejs-producer-lambda-function.lambda_function_name
  function_invoke_arn = module.nodejs-producer-lambda-function.lambda_function_invoke_arn
  enable_xray_tracing = false // ensure xray doesn't modify the trace context. See AWS Lambda Function attribute `tracing_mode` above

}