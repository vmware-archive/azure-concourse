///////////////////////////////////////////////
//////// Pivotal Customer[0] //////////////////
//////// Set Azure DNS references /////////////
///////////////////////////////////////////////

resource "azurerm_dns_zone" "env_dns_zone" {
  name                = "${var.env_name}.${var.dns_suffix}"
  resource_group_name = "${var.env_name}"
}

resource "azurerm_dns_a_record" "ops_manager_dns" {
  name                = "pcf"
  zone_name           = "${azurerm_dns_zone.env_dns_zone.name}"
  resource_group_name = "${var.env_name}"
  ttl                 = "60"
  records             = ["${var.pub_ip_opsman_vm}"]
}

resource "azurerm_dns_a_record" "apps" {
  name                = "*.apps"
  zone_name           = "${azurerm_dns_zone.env_dns_zone.name}"
  resource_group_name = "${var.env_name}"
  ttl                 = "60"
  records             = ["${var.pub_ip_pcf_lb}"]
}

resource "azurerm_dns_a_record" "sys" {
  name                = "*.sys"
  zone_name           = "${azurerm_dns_zone.env_dns_zone.name}"
  resource_group_name = "${var.env_name}"
  ttl                 = "60"
  records             = ["${var.pub_ip_pcf_lb}"]
}

resource "azurerm_dns_a_record" "mysql" {
  name                = "mysql"
  zone_name           = "${azurerm_dns_zone.env_dns_zone.name}"
  resource_group_name = "${var.env_name}"
  ttl                 = "60"
  records             = ["${var.pub_ip_id_mysql_lb}"]
}

resource "azurerm_dns_a_record" "tcp" {
  name                = "tcp"
  zone_name           = "${azurerm_dns_zone.env_dns_zone.name}"
  resource_group_name = "${var.env_name}"
  ttl                 = "60"
  records             = ["${var.pub_ip_pcf_lb}"]
}
