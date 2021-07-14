output "consumer-api-gateway-url" {
  value = module.consumer-api-gateway.api_gateway_url
}

output "producer-api-gateway-url" {
  value = module.producer-api-gateway.api_gateway_url
}
