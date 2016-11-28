#!/bin/bash
set -e

if [[ ! $dyn_enabled == true || -z $dyn_enabled ]]; then
  echo "C0 Dyn integration Disabled"
  exit 0
fi

#############################################################
#################### Azure Auth  & functions ##################
#############################################################

azure login --service-principal -u ${azure_service_principal_id} -p ${azure_service_principal_password} --tenant ${azure_tenant_id}

#############################################################
############### Set C0 Dyn DNS             ##################
#############################################################


function fn_get_ip {
     azure_cmd="azure network public-ip list -g ${azure_terraform_prefix} --json | jq '.[] | select( .name | contains(\"${1}\")) | .ipAddress' | tr -d '\"'"
     pub_ip=$(eval $azure_cmd)
     echo $pub_ip
}

function fn_set_dyn_dns {
     curl_cmd="curl \"https://$dyn_user:$dyn_token@members.dyndns.org/v3/update?hostname=$1.$pcf_ert_domain&myip=$2\""
     echo $curl_cmd
     eval $curl_cmd
}

pub_ip_pcf=$(fn_get_ip "web-lb")
pub_ip_tcp_lb=$(fn_get_ip "tcp-lb")
pub_ip_ssh_and_doppler=$(fn_get_ip "web-lb")
pub_ip_jumpbox=$(fn_get_ip "jumpbox")
pub_ip_opsman=$(fn_get_ip "opsman")

fn_set_dyn_dns "api" "$pub_ip_pcf"
fn_set_dyn_dns "opsman" "$pub_ip_opsman"
fn_set_dyn_dns "ssh.sys" "$pub_ip_ssh_and_doppler"
fn_set_dyn_dns "doppler.sys" "$pub_ip_ssh_and_doppler"
fn_set_dyn_dns "loggregator.sys" "$pub_ip_ssh_and_doppler"
fn_set_dyn_dns "tcp" "$pub_ip_tcp_lb"

echo
echo "----------------------------------------------------------------------------------------------"
echo "Sleeping until DNS Cache updates..."
echo "----------------------------------------------------------------------------------------------"


let dns_retries=20
let dns_sleep_seconds=15
for (( z=1; z<${dns_retries}; z++ )); do

    resolve_ip=$(dig opsman.${pcf_ert_domain} | grep -A 1 "ANSWER SECTION" | grep ^opsman | awk '{print$5}')
    if [[ ! $resolve_ip == $pub_ip_opsman ]]; then
      echo "dnsattempt_$z of $dns_retries:DNS not updated yet!!! I expected the new IP of $pub_ip_opsman but got this instead - $resolve_ip"
      sleep $dns_sleep_seconds
    else
      echo "SUCCESS!!! Standard Dyn DNS updated for  ${pcf_ert_domain}"
      exit 0
    fi
done

#echo "FAIL!!! Standard Dyn DNS not updated for  $pcf_ert_domain"
dig opsman.${pcf_ert_domain}

#exit 1
