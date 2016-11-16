#!/bin/bash
set -e

sudo cp tool-om/om-linux /usr/local/bin
sudo chmod 755 /usr/local/bin/om-linux

echo "=============================================================================================="
echo "Deploying Director @ https://opsman.$pcf_ert_domain ..."
echo "=============================================================================================="

# Set JSON Config Template and inster Concourse Parameter Values
json_file_path="azure-concourse/json-opsman/${azure_pcf_terraform_template}"
json_file_template="${json_file_path}/opsman-template.json"
json_file="${json_file_path}/opsman.json"

pcf_ssh_key_priv=$(echo ${pcf_ssh_key_priv} | sed 's/\s\+/\r\n/g')

cp ${json_file_template} ${json_file}

perl -pi -e "s|{{infra_subnet_iaas}}|${azure_terraform_prefix}-virtual-network/${azure_terraform_prefix}-opsman-and-director-subnet|g" ${json_file}
perl -pi -e "s|{{infra_subnet_cidr}}|${azure_terraform_subnet_infra_cidr}|g" ${json_file}
perl -pi -e "s|{{infra_subnet_reserved}}|${azure_terraform_subnet_infra_reserved}|g" ${json_file}
perl -pi -e "s|{{infra_subnet_dns}}|${azure_terraform_subnet_infra_dns}|g" ${json_file}
perl -pi -e "s|{{infra_subnet_gateway}}|${azure_terraform_subnet_infra_gateway}|g" ${json_file}
perl -pi -e "s|{{ert_subnet_iaas}}|${azure_terraform_prefix}-virtual-network/${azure_terraform_prefix}-ert-subnet|g" ${json_file}
perl -pi -e "s|{{ert_subnet_cidr}}|${azure_terraform_subnet_ert_cidr}|g" ${json_file}
perl -pi -e "s|{{ert_subnet_reserved}}|${azure_terraform_subnet_ert_reserved}|g" ${json_file}
perl -pi -e "s|{{ert_subnet_dns}}|${azure_terraform_subnet_ert_dns}|g" ${json_file}
perl -pi -e "s|{{ert_subnet_gateway}}|${azure_terraform_subnet_ert_gateway}|g" ${json_file}
perl -pi -e "s|{{services1_subnet_iaas}}|${azure_terraform_prefix}-virtual-network/${azure_terraform_prefix}-services-01-subnet|g" ${json_file}
perl -pi -e "s|{{services1_subnet_cidr}}|${azure_terraform_subnet_services1_cidr}|g" ${json_file}
perl -pi -e "s|{{services1_subnet_reserved}}|${azure_terraform_subnet_services1_reserved}|g" ${json_file}
perl -pi -e "s|{{services1_subnet_dns}}|${azure_terraform_subnet_services1_dns}|g" ${json_file}
perl -pi -e "s|{{services1_subnet_gateway}}|${azure_terraform_subnet_services1_gateway}|g" ${json_file}




# Exec bash scripts to config Opsman Director Tile
./azure-concourse/json-opsman/config-director-json.sh azure director

# Apply Changes in Opsman

#om-linux --target https://opsman.$pcf_ert_domain -k \
#       --username "$pcf_opsman_admin" \
#       --password "$pcf_opsman_admin_passwd" \
#  apply-changes
