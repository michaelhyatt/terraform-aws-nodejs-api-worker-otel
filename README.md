# Instrumenting AWS Lambda Node.js functions with OpenTelemetry SDK and Elastic Observability 

## Getting started
This tutorial explains how to instrument Python lambda functions with the OpenTelemetry SDK (ie manual instrumentation of the code). For auto instrumentation via the OpenTelemetry Auto Instrumentation Python Agent, see [AWS Distro for OpenTelemetry Lambda Support For JS)](https://aws-otel.github.io/docs/getting-started/lambda/lambda-js)

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
   * [Function layer](https://docs.aws.amazon.com/lambda/latest/dg/API_Layer.html): The latest [AWS Lambda layer for OpenTelemetry]https://aws-otel.github.io/docs/getting-started/lambda/lambda-js)  (e.g. `arn:aws:lambda:us-east-1:901920570463:layer:aws-otel-nodejs-ver-0-23-0:1`)
   * [TracingConfig / Mode](https://docs.aws.amazon.com/lambda/latest/dg/API_TracingConfig.html) set to `PassTrough`
   * Export the environment variables:
      * `AWS_LAMBDA_EXEC_WRAPPER="/opt/otel-handler"`.
      * `OTEL_PROPAGATORS="tracecontext"` to override the default setting that also enables X-Ray headers causing interferences between OpenTelemetry and X-Ray.
      * `OPENTELEMETRY_COLLECTOR_CONFIG_FILE="/var/task/opentelemetry-collector.yaml"` to specify the path to your OpenTelemetry Collector configuration.
      * Note that this environment variable is required to be set until [ pull request](https://github.com/open-telemetry/opentelemetry-js/pull/2331) is merged and released:
        `OTEL_EXPORTER_OTLP_ENDPOINT: "http://localhost:55681/v1/traces"`
      * Turn on sampling, if `traceparent` header is not sent from the caller. This can potentially create a very large amount of data, so in production set the correct sampling configuration, as per [specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/sdk.md#sampling).
        `OTEL_TRACES_SAMPLER: "AlwaysOn"`

* Deploy your Lambda function, test it and visualize it in Elastic Observability's APM view:
    * Example distributed trace chaining 2 lambda functions and [provided Node.js client](client):
      ![image](https://user-images.githubusercontent.com/15670925/125717724-3fb69534-aab9-41cd-98e7-f841b5b6df9e.png)


    * Example of the above trace represented as a service map:
      ![image](https://user-images.githubusercontent.com/15670925/125717927-4c47590f-e289-411b-a570-f14722adb13c.png)
      

## Terraform deployment example
See
* [Deploymet folder](deploy) 
* [Node.js client to create distributed traces](client)
