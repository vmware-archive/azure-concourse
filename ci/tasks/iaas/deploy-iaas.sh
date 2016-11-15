#!/bin/bash
set -e

# Get Opsman VHD from previous task
pcf_opsman_image_uri=$(cat opsman-metadata/uri)

# Get Public IPs
azure login --service-principal -u ${azure_service_principal_id} -p ${azure_service_principal_password} --tenant ${azure_tenant_id}

function fn_get_ip {
     azure_cmd="azure network public-ip list -g c0-opsman-validation --json | jq '.[] | select( .name | contains(\"${1}\")) | .ipAddress' | tr -d '\"'"
     pub_ip=$(eval $azure_cmd)
     echo $pub_ip
}

function fn_get_ip_ref_id {
     azure_cmd="azure network public-ip list -g c0-opsman-validation --json | jq '.[] | select( .name | contains(\"${1}\")) | .id' | tr -d '\"'"
     pub_ip=$(eval $azure_cmd)
     echo $pub_ip
}

pub_ip_pcf=$(fn_get_ip "web-lb")
pub_ip_id_pcf=$(fn_get_ip_ref_id "web-lb")

pub_ip_tcp_lb=$(fn_get_ip "tcp-lb")
pub_ip_id_tcp_lb=$(fn_get_ip_ref_id "tcp-lb")

pub_ip_ssh_and_doppler=$(fn_get_ip "web-lb")

pub_ip_jumpbox=$(fn_get_ip "jumpbox")

pub_ip_opsman=$(fn_get_ip "opsman")
pub_ip_id_opsman=$(n_get_ip_ref_id "opsman")

env_shortname=$(echo ${azure_terraform_prefix} | tr -d "-" | tr -d "_" | tr -d "[0-9]")
env_shortname=$(echo ${env_shortname:0:10})

echo "=============================================================================================="
echo "Executing Terraform ...."
echo "=============================================================================================="

export PATH=/opt/terraform/terraform:$PATH

/opt/terraform/terraform plan \
  -var "subscription_id=${azure_subscription_id}" \
  -var "client_id=${azure_service_principal_id}" \
  -var "client_secret=${azure_service_principal_password}" \
  -var "tenant_id=${azure_tenant_id}" \
  -var "location=${azure_region}" \
  -var "env_name=${azure_terraform_prefix}" \
  -var "env_short_name=${env_short_name}" \
  -var "dns_suffix=${pcf_ert_domain}" \
  -var "pub_ip_opsman=${pub_ip_opsman}" \
  -var "pub_ip_pcf=${pub_ip_pcf}" \
  -var "pub_ip_id_pcf=${pub_ip_id_pcf}" \
  -var "pub_ip_id_tcp_lb=${pub_ip_id_tcp_lb}" \
  -var "pcf_opsman_image_uri=${pcf_opsman_image_uri}" \
  azure-concourse/terraform/$azure_pcf_terraform_template
