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
   * [Function layer](https://docs.aws.amazon.com/lambda/latest/dg/API_Layer.html): The latest [AWS Lambda layer for OpenTelemetry]https://aws-otel.github.io/docs/getting-started/lambda/lambda-js)  (e.g. `arn:aws:lambda:us-east-1:901920570463:layer:aws-otel-nodejs-ver-0-19-0:1`)
   * [TracingConfig / Mode](https://docs.aws.amazon.com/lambda/latest/dg/API_TracingConfig.html) set to `PassTrough`
   * Export the environment variables:
      * `AWS_LAMBDA_EXEC_WRAPPER="/opt/otel-handler"`.
      * `OTEL_PROPAGATORS="tracecontext"` to override the default setting that also enables X-Ray headers causing interferences between OpenTelemetry and X-Ray.
      * `OPENTELEMETRY_COLLECTOR_CONFIG_FILE="/var/task/opentelemetry-collector.yaml"` to specify the path to your OpenTelemetry Collector configuration.
      * Note that due to [this limitation](https://github.com/aws-observability/aws-otel-lambda/issues/118) for the trace to work it requires the `traceparent` header to be sent to the first lambda with the `sampled` flag set to true. If you are using the provided [client.js](client/client.js) example, it should take care of that.

* Deploy your Lambda function, test it and visualize it in Elastic Observability's APM view:
    * Example distributed trace chaining 2 lambda functions and [provided Node.js client](client):
      ![image](https://user-images.githubusercontent.com/15670925/125717724-3fb69534-aab9-41cd-98e7-f841b5b6df9e.png)


    * Example of the above trace represented as a service map:
      ![image](https://user-images.githubusercontent.com/15670925/125717927-4c47590f-e289-411b-a570-f14722adb13c.png)
      

## Terraform deployment example
See
* [Deploymet folder](deploy) 
* [Node.js client to create distributed traces](client)
