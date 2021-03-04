resource "random_id" "storage_name" {
  keepers = {
    resource_group = azurerm_resource_group.rg.name
  }
  byte_length = 8
}

resource "azurerm_storage_account" "storage" {
  name                     = "sta${lower(random_id.storage_name.hex)}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "scripts" {
  name                  = local.storage_container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "devops" {
  name                  = local.storage_devops_container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "InstallAgent" {
  name                   = "InstallAgent.ps1"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source                 = "${path.module}/scripts/InstallAgent.ps1"
}

resource "azurerm_storage_blob" "InstallChocolateyComponents" {
  name                   = "InstallChocolateyComponents.ps1"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source                 = "${path.module}/scripts/InstallChocolateyComponents.ps1"
}

resource "azurerm_storage_share" "deployshare" {
  name                 = "deploys"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 50

  acl {
    id = "deploysharerwdl"

    access_policy {
      permissions = "rwdl"
    }
  }
}

