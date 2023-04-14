/* providers.tf */
terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

/* variables.tf */
variable "name_prefix" {
  default     = "postgresql-fs"
  description = "Prefix of the resource name."
}

variable "location" {
  default     = "centralindia"
  description = "Location of the resource."
}

/* main.tf */
resource "random_pet" "name_prefix" {
  prefix = var.name_prefix
  length = 1
}

resource "random_password" "pass" {
  length = 20
}

resource "azurerm_resource_group" "default" {
  name     = random_pet.name_prefix.id
  location = var.location
}

resource "azurerm_postgresql_flexible_server" "default" {
  name                   = "${random_pet.name_prefix.id}-server"
  resource_group_name    = azurerm_resource_group.default.name
  location               = azurerm_resource_group.default.location
  version                = "14"
  administrator_login    = "postgres"
  administrator_password = random_password.pass.result
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
  backup_retention_days  = 7
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "example" {
  name             = "all-access-fr"
  server_id        = azurerm_postgresql_flexible_server.default.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

/* postgresql-fs-db.tf */
resource "azurerm_postgresql_flexible_server_database" "default" {
  name      = "${random_pet.name_prefix.id}-db"
  server_id = azurerm_postgresql_flexible_server.default.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}

/* outputs.tf */
output "resource_group" {
  value = azurerm_resource_group.default.name
}

output "db_url" {
  value = azurerm_postgresql_flexible_server.default.fqdn
}

output "db_name" {
  value = azurerm_postgresql_flexible_server_database.default.name
}

output "db_user" {
  value = azurerm_postgresql_flexible_server.default.administrator_login
}

output "db_password" {
  sensitive = true
  value     = azurerm_postgresql_flexible_server.default.administrator_password
}
