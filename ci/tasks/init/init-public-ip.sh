#!/bin/bash
set -e

echo "=============================================================================================="
echo "Executing Terraform ...."
echo "=============================================================================================="

# Copy base template with no clobber if not using the base template
if [[ ! ${azure_pcf_terraform_template} == "c0-azure-base" ]]; then
  cp -rn azure-concourse/terraform/c0-azure-base/* azure-concourse/terraform/${azure_pcf_terraform_template}/
fi

export PATH=/opt/terraform/terraform:$PATH

/opt/terraform/terraform plan \
  -var "subscription_id=${azure_subscription_id}" \
  -var "client_id=${azure_service_principal_id}" \
  -var "client_secret=${azure_service_principal_password}" \
  -var "tenant_id=${azure_tenant_id}" \
  -var "location=${azure_region}" \
  -var "env_name=${azure_terraform_prefix}"
  azure-concourse/terraform/${azure_pcf_terraform_template}/init

exit 1

/opt/terraform/terraform apply \
  -var "gcp_proj_id=$gcp_proj_id" \
  -var "gcp_region=$gcp_region" \
  -var "gcp_terraform_prefix=$gcp_terraform_prefix" \
  gcp-concourse/terraform/$gcp_pcf_terraform_template/init



echo "=============================================================================================="
echo "This gcp_pcf_terraform_template has an 'Init' set of terraform that has pre-created IPs..."
echo "=============================================================================================="
echo $gcp_svc_acct_key > /tmp/blah
gcloud auth activate-service-account --key-file /tmp/blah
rm -rf /tmp/blah

gcloud config set project $gcp_proj_id
gcloud config set compute/region $gcp_region

function fn_get_ip {
     gcp_cmd="gcloud compute addresses list  --format json | jq '.[] | select (.name == \"$gcp_terraform_prefix-$1\") | .address '"
     api_ip=$(eval $gcp_cmd | tr -d '"')
     echo $api_ip
}

pub_ip_global_pcf=$(fn_get_ip "global-pcf")
pub_ip_ssh_tcp_lb=$(fn_get_ip "tcp-lb")
pub_ip_ssh_and_doppler=$(fn_get_ip "ssh-and-doppler")
pub_ip_jumpbox=$(fn_get_ip "jumpbox")
pub_ip_opsman=$(fn_get_ip "opsman")

echo "You have now deployed Public IPs to GCP that must be resolvable to:"
echo "----------------------------------------------------------------------------------------------"
echo "*.sys.${pcf_ert_domain} == ${pub_ip_global_pcf}"
echo "*.cfapps.${pcf_ert_domain} == ${pub_ip_global_pcf}"
echo "ssh.sys.${pcf_ert_domain} == ${pub_ip_ssh_and_doppler}"
echo "doppler.sys.${pcf_ert_domain} == ${pub_ip_ssh_and_doppler}"
echo "loggregator.sys.${pcf_ert_domain} == ${pub_ip_ssh_and_doppler}"
echo "tcp.${pcf_ert_domain} == ${pub_ip_ssh_tcp_lb}"
echo "opsman.${pcf_ert_domain} == ${pub_ip_opsman}"
echo "----------------------------------------------------------------------------------------------"
echo "DO Not Start the 'deploy-iaas' Concourse Job of this Pipeline until you have confirmed that DNS is reolving correctly.  Failure to do so will result in a FAIL!!!!"
