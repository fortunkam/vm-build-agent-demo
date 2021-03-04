resource "random_password" "vm" {
  keepers = {
    resource_group = azurerm_resource_group.rg.name
  }
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_network_interface" "vm" {
  name                = local.build_vm_nic_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = local.build_vm_nic_ipconfig
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.build.id
    primary = true
  }
}

resource "azurerm_network_security_group" "vm" {
  name                = local.build_vm_nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "rdp" {
  name                        = "rdp"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.vm.name
}

resource "azurerm_network_interface_security_group_association" "vm" {
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = local.build_vm_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size = "Standard_DS1_v2"
  admin_username = local.build_vm_username
  admin_password = random_password.vm.result
  provision_vm_agent = true

   network_interface_ids = [
        azurerm_network_interface.vm.id
    ]

  source_image_reference  {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  os_disk {
    name              = local.build_vm_disk
    caching           = "ReadWrite"
    storage_account_type  = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "storageblobreader" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_windows_virtual_machine.vm.identity[0].principal_id
}

resource "azurerm_virtual_machine_extension" "installAgent" {
  name                 = "installAgent"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "fileUris": [
            "${azurerm_storage_blob.InstallAgent.url}",
            "${azurerm_storage_blob.InstallChocolateyComponents.url}"
        ]
    }
SETTINGS
    protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File InstallAgent.ps1 -patToken \"${var.devops_pat_token}\" -devopsUrl \"${var.devops_uri}\" -agentPool \"${var.devops_agent_pool}\" -agentName \"${azurerm_windows_virtual_machine.vm.name}\"",
        "managedIdentity" : {}
    }
PROTECTED_SETTINGS
    depends_on = [azurerm_storage_blob.InstallAgent]

    lifecycle {
        ignore_changes = all
    }

     timeouts {
        create = "2h"
        delete = "2h"
    }
}

