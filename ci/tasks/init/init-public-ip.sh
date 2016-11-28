#!/bin/bash
set -e

echo "=============================================================================================="
echo "Executing Terraform ...."
echo "=============================================================================================="

# Copy base template with no clobber if not using the base template
if [[ ! ${azure_pcf_terraform_template} == "c0-azure-base" ]]; then
  cp -rn azure-concourse/terraform/c0-azure-base/* azure-concourse/terraform/${azure_pcf_terraform_template}/
fi

export PATH=/opt/terraform:$PATH

/opt/terraform/terraform plan \
  -var "subscription_id=${azure_subscription_id}" \
  -var "client_id=${azure_service_principal_id}" \
  -var "client_secret=${azure_service_principal_password}" \
  -var "tenant_id=${azure_tenant_id}" \
  -var "location=${azure_region}" \
  -var "env_name=${azure_terraform_prefix}" \
  azure-concourse/terraform/${azure_pcf_terraform_template}/init


/opt/terraform/terraform apply \
  -var "subscription_id=${azure_subscription_id}" \
  -var "client_id=${azure_service_principal_id}" \
  -var "client_secret=${azure_service_principal_password}" \
  -var "tenant_id=${azure_tenant_id}" \
  -var "location=${azure_region}" \
  -var "env_name=${azure_terraform_prefix}" \
  azure-concourse/terraform/${azure_pcf_terraform_template}/init


echo "=============================================================================================="
echo "This azure_pcf_terraform_template has an 'Init' set of terraform that has pre-created IPs..."
echo "=============================================================================================="


azure login --service-principal -u ${azure_service_principal_id} -p ${azure_service_principal_password} --tenant ${azure_tenant_id}



function fn_get_ip {
     azure_cmd="azure network public-ip list -g ${azure_terraform_prefix} --json | jq '.[] | select( .name | contains(\"${1}\")) | .ipAddress' | tr -d '\"'"
     pub_ip=$(eval $azure_cmd)
     echo $pub_ip
}

pub_ip_pcf=$(fn_get_ip "web-lb")
pub_ip_tcp_lb=$(fn_get_ip "tcp-lb")
pub_ip_ssh_and_doppler=$(fn_get_ip "web-lb")
pub_ip_jumpbox=$(fn_get_ip "jumpbox")
pub_ip_opsman=$(fn_get_ip "opsman")

echo "You have now deployed Public IPs to azure that must be resolvable to:"
echo "----------------------------------------------------------------------------------------------"
echo "*.sys.${pcf_ert_domain} == ${pub_ip_pcf}"
echo "*.cfapps.${pcf_ert_domain} == ${pub_ip_pcf}"
echo "ssh.sys.${pcf_ert_domain} == ${pub_ip_ssh_and_doppler}"
echo "doppler.sys.${pcf_ert_domain} == ${pub_ip_ssh_and_doppler}"
echo "loggregator.sys.${pcf_ert_domain} == ${pub_ip_ssh_and_doppler}"
echo "tcp.${pcf_ert_domain} == ${pub_ip_tcp_lb}"
echo "opsman.${pcf_ert_domain} == ${pub_ip_opsman}"
echo "----------------------------------------------------------------------------------------------"
echo "DO Not Start the 'deploy-iaas' Concourse Job of this Pipeline until you have confirmed that DNS is reolving correctly.  Failure to do so will result in a FAIL!!!!"
