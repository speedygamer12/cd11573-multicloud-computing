resource "azurerm_resource_group" "udacity" {
  name     = "udacity-resources"
  location = "North Central US"
}

# resource "random_integer" "ri" {
#   min = 10000
#   max = 99999
# }

# resource "azurerm_cosmosdb_account" "db" {
#   name                = "tfex-cosmos-db-${random_integer.ri.result}"
#   location            = azurerm_resource_group.udacity.location
#   resource_group_name = azurerm_resource_group.udacity.name
#   offer_type          = "Standard"
#   kind                = "MongoDB"

#   enable_automatic_failover = true

#   capabilities {
#     name = "EnableAggregationPipeline"
#   }

#   capabilities {
#     name = "mongoEnableDocLevelTTL"
#   }

#   capabilities {
#     name = "MongoDBv3.4"
#   }

#   capabilities {
#     name = "EnableMongo"
#   }

#   consistency_policy {
#     consistency_level       = "BoundedStaleness"
#     max_interval_in_seconds = 300
#     max_staleness_prefix    = 100000
#   }

#   geo_location {
#     location          = "eastus"
#     failover_priority = 1
#   }

#   geo_location {
#     location          = "westus"
#     failover_priority = 0
#   }
# }

# data "azurerm_cosmosdb_account" "example" {
#   name                = azurerm_cosmosdb_account.db.name
#   resource_group_name = azurerm_resource_group.udacity.name
# }

# resource "azurerm_cosmosdb_mongo_database" "example" {
#   name                = "tfex-cosmos-mongo-db"
#   resource_group_name = data.azurerm_cosmosdb_account.example.resource_group_name
#   account_name        = data.azurerm_cosmosdb_account.example.name
# }

# resource "azurerm_cosmosdb_mongo_collection" "example" {
#   name                = "tfex-cosmos-mongo-db"
#   resource_group_name = data.azurerm_cosmosdb_account.example.resource_group_name
#   account_name        = data.azurerm_cosmosdb_account.example.name
#   database_name       = azurerm_cosmosdb_mongo_database.example.name

#   default_ttl_seconds = "777"
#   shard_key           = "uniqueKey"
#   throughput          = 400

#   index {
#     keys   = ["_id"]
#     unique = true
#   }
# }

resource "azurerm_storage_account" "example" {
  name                     = "udacityfunctionapp"
  resource_group_name      = azurerm_resource_group.udacity.name
  location                 = azurerm_resource_group.udacity.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "example" {
  name                = "example-app-service-plan"
  resource_group_name = azurerm_resource_group.udacity.name
  location            = azurerm_resource_group.udacity.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_windows_function_app" "example" {
  name                = "udacity-tscotto-windows-function-app"
  resource_group_name = azurerm_resource_group.udacity.name
  location            = azurerm_resource_group.udacity.location

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  service_plan_id            = azurerm_service_plan.example.id

  site_config {}
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1"
  location            = azurerm_resource_group.udacity.location
  resource_group_name = azurerm_resource_group.udacity.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw

  sensitive = true
}