///////////////////////////////////////////////
//////// Pivotal Customer[0] //////////////////
//////// Build VNET and Subnets ///////////////
///////////////////////////////////////////////

resource "azurerm_virtual_network" "pcf_virtual_network" {
  name                = "${var.env_name}-virtual-network"
  resource_group_name = "${var.env_name}"
  address_space       = ["192.168.0.0/20"]
  location            = "${var.location}"
}

resource "azurerm_subnet" "opsman_and_director_subnet" {
  name                 = "${var.env_name}-opsman-and-director-subnet"
  resource_group_name  = "${var.env_name}"
  virtual_network_name = "${azurerm_virtual_network.pcf_virtual_network.name}"
  address_prefix       = "192.168.100.0/26"
}

resource "azurerm_subnet" "ert_subnet" {
  name                 = "${var.env_name}-ert-subnet"
  resource_group_name  = "${var.env_name}"
  virtual_network_name = "${azurerm_virtual_network.pcf_virtual_network.name}"
  address_prefix       = "192.168.8.0/22"
}

resource "azurerm_subnet" "services_subnet" {
  name                 = "${var.env_name}-services-01-subnet"
  resource_group_name  = "${var.env_name}"
  virtual_network_name = "${azurerm_virtual_network.pcf_virtual_network.name}"
  address_prefix       = "192.168.12.0/22"
}

resource "azurerm_subnet" "dynamic_services_subnet" {
  name                 = "${var.env_name}-services-dynamic-subnet"
  resource_group_name  = "${var.env_name}"
  virtual_network_name = "${azurerm_virtual_network.pcf_virtual_network.name}"
  address_prefix       = "192.168.16.0/22"
}
