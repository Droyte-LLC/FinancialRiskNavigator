output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "cosmosdb_account_endpoint" {
  description = "Cosmos DB URI endpoint"
  value       = azurerm_cosmosdb_account.cosmos.endpoint
}

output "function_app_url" {
  description = "Default hostname for the Function App"
  value       = azurerm_linux_function_app.function.default_hostname
}

output "eventhub_namespace_name" {
  description = "The name of the Event Hub namespace"
  value       = azurerm_eventhub_namespace.eh_ns.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

output "servicebus_queue_id" {
  description = "ID of the Service Bus queue"
  value       = azurerm_servicebus_queue.queue.id
}
