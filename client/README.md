# Nodejs client with Elastic APM to invoke the example
This is a Nodejs client that can be used to invoke the deployed lambdas and start a distributed trace by sending a `traceparent` header to the first API gateway causing the OpenTelemetry agents to report their spans as belonging to this trace.

## Setup
This client requires `nodejs`. The required JS modules are installed in the node_modules directory, so no additional installs are required.
The `client.js` script relies on APM server connection parameters that spacified in [deploy/env.auto.tfvars.json](../deploy/env.auto.tfvars.json) file.

## Invoke
After the lambdas are deployed, invoke the `producer` lambda using its url reported by terraform:
```
NODE_DEBUG=request node client.js https://XXXXXXXXX.execute-api.ap-southeast-2.amazonaws.com/default
```
It should report a whole bunch of lines with the following at end:
```
REQUEST end event https://xxxxx.execute-api.ap-southeast-2.amazonaws.com/default
REQUEST emitting complete https://xxxxxx.execute-api.ap-southeast-2.amazonaws.com/default
Status: 200
```
This should start generating traces in Kibana.