// Run the client: 
//  NODE_DEBUG=request node client.js https://XXXXXXXXX.execute-api.ap-southeast-2.amazonaws.com/default

const request = require('request');
const apm_config = require('../deploy/env.auto.tfvars.json')

var apm = require('elastic-apm-node').start({
    serviceName: 'node-client',
    secretToken: apm_config['elastic_otlp_token'],
    serverUrl: "https://" + apm_config['elastic_otlp_endpoint'],
});

const transaction = apm.startTransaction("client-top-level");

const span = transaction.startSpan("client-request", "app", "http");

const options = {
    url: process.argv[2],
    headers: {
        "traceparent": span.traceparent,
        "Content-Type": "application/json"
    },
    body: JSON.stringify({
        name: "John"
    })
};

request.post(options, (err, res, body) => {
    
    if (err) {
        return console.log(err);
    }

    console.log(`Status: ${res.statusCode}`);
    console.log(body);
    
    span.end();

    transaction.end();

});
