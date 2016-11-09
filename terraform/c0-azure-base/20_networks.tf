///////////////////////////////////////////////
//////// Pivotal Customer[0] //////////////////
//////// Build VNET and Subnets ///////////////
///////////////////////////////////////////////

resource "azurerm_virtual_network" "pcf_virtual_network" {
  name                = "${var.env_name}-virtual-network"
  depends_on          = ["azurerm_resource_group.pcf_resource_group"]
  resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"
  address_space       = ["192.168.0.0/16"]
  location            = "${var.location}"
}

resource "azurerm_subnet" "opsman_and_director_subnet" {
  name                 = "${var.env_name}-opsman-and-director-subnet"
  depends_on           = ["azurerm_resource_group.pcf_resource_group"]
  resource_group_name  = "${azurerm_resource_group.pcf_resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.pcf_virtual_network.name}"
  address_prefix       = "192.168.100.0/26"
}

resource "azurerm_subnet" "ert_subnet" {
  name                 = "${var.env_name}-ert-subnet"
  depends_on           = ["azurerm_resource_group.pcf_resource_group"]
  resource_group_name  = "${azurerm_resource_group.pcf_resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.pcf_virtual_network.name}"
  address_prefix       = "192.168.8.0/22"
}

resource "azurerm_subnet" "services_subnet" {
  name                 = "${var.env_name}-services-01-subnet"
  depends_on           = ["azurerm_resource_group.pcf_resource_group"]
  resource_group_name  = "${azurerm_resource_group.pcf_resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.pcf_virtual_network.name}"
  address_prefix       = "192.168.12.0/22"
}
