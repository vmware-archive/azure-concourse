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
  records             = ["${var.pub_ip_opsman}"]
}

resource "azurerm_dns_a_record" "apps" {
  name                = "*.apps"
  zone_name           = "${azurerm_dns_zone.env_dns_zone.name}"
  resource_group_name = "${var.env_name}"
  ttl                 = "60"
  records             = ["${var.pub_ip_pcf}"]
}

resource "azurerm_dns_a_record" "sys" {
  name                = "*.sys"
  zone_name           = "${azurerm_dns_zone.env_dns_zone.name}"
  resource_group_name = "${var.env_name}"
  ttl                 = "60"
  records             = ["${var.pub_ip_pcf}"]
}

resource "azurerm_dns_a_record" "mysql" {
  name                = "mysql"
  zone_name           = "${azurerm_dns_zone.env_dns_zone.name}"
  resource_group_name = "${var.env_name}"
  ttl                 = "60"
  records             = ["${azurerm_lb.mysql.frontend_ip_configuration.0.private_ip_address}"]
}

resource "azurerm_dns_a_record" "tcp" {
  name                = "tcp"
  zone_name           = "${azurerm_dns_zone.env_dns_zone.name}"
  resource_group_name = "${var.env_name}"
  ttl                 = "60"
  records             = ["${var.pub_ip_pcf}"]
}
