# ----------------------------
# 1. Resource Group
# ----------------------------
# Central container for all Azure resources.
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# ----------------------------
# 2. Azure Client Context
# ----------------------------
# Used to get the tenant and object ID for Key Vault access policy.
data "azurerm_client_config" "current" {}

# ----------------------------
# 3. Storage for Event Hub Capture
# ----------------------------
# Storage account for Event Hub capture — stores incoming data in Blob storage.
resource "azurerm_storage_account" "data_lake" {
  name                     = var.storage_data_lake_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Container to hold captured Event Hub data.
resource "azurerm_storage_container" "capture" {
  name                  = var.store_lake_container_name
  storage_account_id    = azurerm_storage_account.data_lake.id
  container_access_type = "private"
}

# ----------------------------
# 4. Cosmos DB Account
# ----------------------------
# Serverless database used for storing structured data (e.g., metadata, telemetry).
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = var.cosmos_account_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  consistency_policy {
    consistency_level = "Session"
  }

  capabilities {
    name = "EnableServerless"
  }
}

# ----------------------------
# 5. Event Hub Namespace
# ----------------------------
# Container for managing Event Hubs (used for event ingestion and streaming).
resource "azurerm_eventhub_namespace" "eh_ns" {
  name                = var.eventhub_namespace
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
}

# ----------------------------
# 6. Event Hub with Capture
# ----------------------------
# Primary ingestion point for incoming events, with automatic capture to Blob storage.
resource "azurerm_eventhub" "ingest" {
  name              = "${var.prefix}-ingest"
  namespace_id      = azurerm_eventhub_namespace.eh_ns.id
  partition_count   = 4
  message_retention = 1

  capture_description {
    enabled             = true
    encoding            = "Avro"
    interval_in_seconds = 300
    size_limit_in_bytes = 314572800

    destination {
      name                = "EventHubArchive.AzureBlockBlob"
      storage_account_id  = azurerm_storage_account.data_lake.id
      blob_container_name = azurerm_storage_container.capture.name
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
    }
  }
}

# ----------------------------
# 7. Optional: Additional Event Hub (for separation or testing)
# ----------------------------
resource "azurerm_eventhub" "eh" {
  name              = var.eventhub_name
  namespace_id      = azurerm_eventhub_namespace.eh_ns.id
  partition_count   = 2
  message_retention = 1

  capture_description {
    enabled             = true
    encoding            = "Avro"
    interval_in_seconds = 300
    size_limit_in_bytes = 314572800

    destination {
      name                = "EventHubArchive.AzureBlockBlob"
      storage_account_id  = azurerm_storage_account.data_lake.id
      blob_container_name = azurerm_storage_container.capture.name
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
    }
  }
}

# ----------------------------
# 8. Function App Storage
# ----------------------------
# Required backing storage account for the Azure Function App.
resource "azurerm_storage_account" "function_sa" {
  name                     = var.function_storage_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# ----------------------------
# 9. App Service Plan
# ----------------------------
# Basic App Service Plan for the Azure Function App.
resource "azurerm_service_plan" "plan" {
  name                = var.app_service_plan
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1" # Basic tier for development/testing
}

# ----------------------------
# 10. Azure Function App
# ----------------------------
# Executes backend logic (e.g., processing events, transforming data).
resource "azurerm_linux_function_app" "function" {
  name                       = var.function_app_name
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.function_sa.name
  storage_account_access_key = azurerm_storage_account.function_sa.primary_access_key

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }
}

# ----------------------------
# 11. Key Vault
# ----------------------------
# Used to store secrets securely (e.g., connection strings, credentials).
resource "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "Set", "List"]
  }
}

# ----------------------------
# 12. Service Bus Namespace
# ----------------------------
# Used for messaging between microservices or downstream systems.
resource "azurerm_servicebus_namespace" "sb_ns" {
  name                = var.servicebus_namespace
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
}

# ----------------------------
# 13. Service Bus Queue
# ----------------------------
# Queue to store messages for asynchronous processing.
resource "azurerm_servicebus_queue" "queue" {
  name         = var.servicebus_queue
  namespace_id = azurerm_servicebus_namespace.sb_ns.id
}

# ----------------------------
# 14. Azure Machine Learning Workspace
# ----------------------------
# Workspace for managing machine learning experiments and models.
resource "azurerm_application_insights" "ml_ai" {
  name                = "ml-ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_storage_account" "ml_sa" {
  name                     = "mlstorage${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_machine_learning_workspace" "ml_ws" {
  name                = "ml-workspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  application_insights_id = azurerm_application_insights.ml_ai.id
  key_vault_id            = azurerm_key_vault.kv.id
  storage_account_id      = azurerm_storage_account.ml_sa.id

  sku_name = "Basic"

  identity {
    type = "SystemAssigned"
  }
}