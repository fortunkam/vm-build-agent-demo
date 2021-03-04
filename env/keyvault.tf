resource "azurerm_key_vault" "keyvault" {
  name                = local.keyvault_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment = true
  enabled_for_template_deployment = true

  sku_name = "standard"
}

# resource "azurerm_key_vault_access_policy" "user" {
#   key_vault_id = azurerm_key_vault.keyvault.id

#   tenant_id = data.azurerm_client_config.current.tenant_id
#   object_id = data.azurerm_client_config.current.object_id

#   certificate_permissions = [
#     "create",
#     "delete",
#     "deleteissuers",
#     "get",
#     "getissuers",
#     "import",
#     "list",
#     "listissuers",
#     "managecontacts",
#     "manageissuers",
#     "setissuers",
#     "update",
#   ]

#   key_permissions = [
#     "backup",
#     "create",
#     "decrypt",
#     "delete",
#     "encrypt",
#     "get",
#     "import",
#     "list",
#     "purge",
#     "recover",
#     "restore",
#     "sign",
#     "unwrapKey",
#     "update",
#     "verify",
#     "wrapKey",
#   ]

#   secret_permissions = [
#     "backup",
#     "delete",
#     "get",
#     "list",
#     "purge",
#     "recover",
#     "restore",
#     "set",
#   ]

# }

resource "azurerm_key_vault_certificate" "winrm_cert" {
  name         = "winrmcert"
  key_vault_id = azurerm_key_vault.keyvault.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1","1.3.6.1.5.5.7.3.2"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject            = "CN=${local.srv_vm_name}"
      validity_in_months = 12
    }
  }
}

resource "azurerm_key_vault_secret" "srv_username" {
  name         = "ServerUserName"
  value        = local.srv_vm_username
  key_vault_id = azurerm_key_vault.keyvault.id
}


resource "azurerm_key_vault_secret" "srv_password" {
  name         = "ServerPassword"
  value        = random_password.srv.result
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "build_username" {
  name         = "DeployUserName"
  value        = local.build_vm_username
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "build_password" {
  name         = "DeployPassword"
  value        = random_password.vm.result
  key_vault_id = azurerm_key_vault.keyvault.id
}
