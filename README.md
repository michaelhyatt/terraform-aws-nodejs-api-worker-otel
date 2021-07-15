# Instrumenting AWS Lambda Node.js functions with OpenTelemetry SDK and Elastic Observability 

## Getting started
This tutorial explains how to instrument Python lambda functions with the OpenTelemetry SDK (ie manual instrumentation of the code). For auto instrumentation via the OpenTelemetry Auto Instrumentation Python Agent, see [AWS Distro for OpenTelemetry Lambda Support For JS)](hhttps://aws-otel.github.io/docs/getting-started/lambda/lambda-js)

* See reference documentation: https://aws-otel.github.io/docs/getting-started/lambda

* No lambda code should require any modifications. Check out [the example](src/handler.js) in this project.

* Add in the root directory of your lambda function (e.g. `src/opentelemetry-collector.yaml`) the configuration of the [AWS Distro for OpenTelemetry Collector](https://github.com/aws-observability/aws-otel-collector) to export the data to Elastic Observability:
    ```yaml
    # Copy opentelemetry-collector.yaml in the root directory of the lambda function
    # Set an environment variable 'OPENTELEMETRY_COLLECTOR_CONFIG_FILE' to '/var/task/opentelemetry-collector.yaml'
    receivers:
      otlp:
        protocols:
          http:
          grpc:
    
    exporters:
      logging:
        loglevel: debug
      otlp/elastic:
        # Elastic APM server https endpoint without the "https://" prefix
        endpoint: "${ELASTIC_OTLP_ENDPOINT}"
        headers:
          # APM Server secret token
          Authorization: "Bearer ${ELASTIC_OTLP_TOKEN}"
    
    service:
      pipelines:
        traces:
          receivers: [otlp]
          exporters: [logging, otlp/elastic]
        metrics:
          receivers: [otlp]
          exporters: [logging, otlp/elastic]
    ```
* Configure you AWS Lambda function with:
   * [Function layer](https://docs.aws.amazon.com/lambda/latest/dg/API_Layer.html): The latest [AWS Lambda layer for OpenTelemetry]https://aws-otel.github.io/docs/getting-started/lambda/lambda-js)  (e.g. `arn:aws:lambda:us-east-1:901920570463:layer:aws-otel-nodejs-ver-0-19-0:1`)
   * [TracingConfig / Mode](https://docs.aws.amazon.com/lambda/latest/dg/API_TracingConfig.html) set to `PassTrough`
   * Export the environment variables:
      * `AWS_LAMBDA_EXEC_WRAPPER="/opt/otel-handler"`.
      * `OTEL_PROPAGATORS="tracecontext"` to override the default setting that also enables X-Ray headers causing interferences between OpenTelemetry and X-Ray.
      * `OPENTELEMETRY_COLLECTOR_CONFIG_FILE="/var/task/opentelemetry-collector.yaml"` to specify the path to your OpenTelemetry Collector configuration.

* Deploy your Lambda function, test it and visualize it in Elastic Observability's APM view:
    * Example distributed trace chaining 2 lambda functions and [provided Node.js client](client):
      

    * Example of the above trace represented as a service map:
      

## Terraform deployment example
See
* [Deploymet folder](deploy) 
* [Node.js client to create distributed traces](client)
