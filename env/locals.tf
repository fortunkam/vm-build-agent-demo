locals {
    rg_name = "${var.prefix}-rg"
    storage_container_name = "scripts"
    build_vm_name = "${var.prefix}-dpy"
    build_vm_disk = "${var.prefix}-dpy-disk"
    build_vm_username = "AzureAdmin"
    build_vm_nic_name = "${var.prefix}-dpy-nic"
    build_vm_nic_ipconfig = "${var.prefix}-dpy-ipconfig"
    build_vm_nsg_name = "${var.prefix}-dpy-nsg"
    vnet_name = "${var.prefix}-vnet"
    vm_subnet_name = "vm"
    vnet_address_space = "10.0.0.0/24"
    vm_subnet_address_prefix = "10.0.0.0/28"
    build_subnet_address_prefix = "10.0.0.16/28"
    build_subnet_name = "build"

    srv_vm_name = "${var.prefix}-vm"
    srv_vm_disk = "${var.prefix}-vm-disk"
    srv_vm_username = "AzureAdmin"
    srv_vm_nic_name = "${var.prefix}-vm-nic"
    srv_vm_nic_ipconfig = "${var.prefix}-vm-ipconfig"
    srv_vm_publicip_name = "${var.prefix}-vm-publicip"
    srv_vm_nsg_name = "${var.prefix}-vm-nsg"
    keyvault_name = "${var.prefix}kv"
    storage_devops_container_name = "devops"
}

data "azurerm_client_config" "current" {
}
data "azurerm_subscription" "primary" {
}