resource "random_password" "srv" {
  keepers = {
    resource_group = azurerm_resource_group.rg.name
  }
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_public_ip" "srv" {
  name                = local.srv_vm_publicip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "srv" {
  name                = local.srv_vm_nic_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = local.srv_vm_nic_ipconfig
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vm.id
    public_ip_address_id          = azurerm_public_ip.srv.id
    primary = true
  }
}

resource "azurerm_network_security_group" "srv" {
  name                = local.srv_vm_nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "vmrdp" {
  name                        = "rdp"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.srv.name
}

resource "azurerm_network_security_rule" "vmhttp" {
  name                        = "http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.srv.name
}

resource "azurerm_network_interface_security_group_association" "srv" {
  network_interface_id      = azurerm_network_interface.srv.id
  network_security_group_id = azurerm_network_security_group.srv.id
}

resource "azurerm_role_assignment" "vmstorageblobreader" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_windows_virtual_machine.srv.identity[0].principal_id
}

resource "azurerm_windows_virtual_machine" "srv" {
  name                = local.srv_vm_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size = "Standard_DS1_v2"
  admin_username = local.srv_vm_username
  admin_password = random_password.srv.result
  provision_vm_agent = true

   network_interface_ids = [
        azurerm_network_interface.srv.id
    ]

  source_image_reference  {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  os_disk {
    name              = local.srv_vm_disk
    caching           = "ReadWrite"
    storage_account_type  = "Standard_LRS"
  }
  winrm_listener {
      protocol = "Https"
      certificate_url = azurerm_key_vault_certificate.winrm_cert.secret_id
  }

  identity {
    type = "SystemAssigned"
  }

  secret {

    certificate {
      store = "My"
      url   = azurerm_key_vault_certificate.winrm_cert.secret_id
    }

    key_vault_id = azurerm_key_vault_certificate.winrm_cert.key_vault_id
   }
}


resource "azurerm_virtual_machine_extension" "installIIS" {
  name                 = "installIIS"
  virtual_machine_id   = azurerm_windows_virtual_machine.srv.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS
}


