#!/bin/bash
set -e

echo "=============================================================================================="
echo "Executing Terraform ...."
echo "=============================================================================================="

pcf_opsman_image_name=$(cat opsman-metadata/name)

export PATH=/opt/terraform/terraform:$PATH
echo $gcp_svc_acct_key > /tmp/svc-acct.json

/opt/terraform/terraform plan \
  -var "gcp_proj_id=$gcp_proj_id" \
  -var "gcp_region=$gcp_region" \
  -var "gcp_zone_1=$gcp_zone_1" \
  -var "gcp_zone_2=$gcp_zone_2" \
  -var "gcp_zone_3=$gcp_zone_3" \
  -var "gcp_terraform_prefix=$gcp_terraform_prefix" \
  -var "gcp_terraform_subnet_ops_manager=$gcp_terraform_subnet_ops_manager" \
  -var "gcp_terraform_subnet_ert=$gcp_terraform_subnet_ert" \
  -var "gcp_terraform_subnet_services_1=$gcp_terraform_subnet_services_1" \
  -var "pcf_opsman_image_name=$pcf_opsman_image_name" \
  -var "pcf_ert_domain=$pcf_ert_domain" \
  -var "pcf_ert_ssl_cert=$pcf_ert_ssl_cert" \
  -var "pcf_ert_ssl_key=$pcf_ert_ssl_key" \
  gcp-concourse/terraform/$gcp_pcf_terraform_template

/opt/terraform/terraform apply \
  -var "gcp_proj_id=$gcp_proj_id" \
  -var "gcp_region=$gcp_region" \
  -var "gcp_zone_1=$gcp_zone_1" \
  -var "gcp_zone_2=$gcp_zone_2" \
  -var "gcp_zone_3=$gcp_zone_3" \
  -var "gcp_terraform_prefix=$gcp_terraform_prefix" \
  -var "gcp_terraform_subnet_ops_manager=$gcp_terraform_subnet_ops_manager" \
  -var "gcp_terraform_subnet_ert=$gcp_terraform_subnet_ert" \
  -var "gcp_terraform_subnet_services_1=$gcp_terraform_subnet_services_1" \
  -var "pcf_opsman_image_name=$pcf_opsman_image_name" \
  -var "pcf_ert_domain=$pcf_ert_domain" \
  -var "pcf_ert_ssl_cert=$pcf_ert_ssl_cert" \
  -var "pcf_ert_ssl_key=$pcf_ert_ssl_key" \
  gcp-concourse/terraform/$gcp_pcf_terraform_template
