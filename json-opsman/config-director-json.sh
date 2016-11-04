############################################################################################################
### name:         config-director-json.sh
### function:     Use curl to automate PCF Opsman Deploys
### use_with:     Opsman 1.8.#
### version:      1.0.0
### last_updated: Oct 2016
### author:       mglynn@pivotal.io
############################################################################################################
############################################################################################################
#!/bin/bash
set -e

############################################################################################################
############################################# Variables  ###################################################
############################################################################################################
provider_type=${1}
config_target=${2}

# Setting exec_mode=LOCAL for debugging, otherise vars get pulled from Concourse
exec_mode="CONCOURSE" # LOCAL|CONCOURSE
  if [[ $exec_mode == "LOCAL" ]]; then
     exec_mode_root="."
     pcf_opsman_admin="admin"
     pcf_opsman_admin_passwd='P1v0t4l!'
     pcf_ert_domain="gcp.customer0.net"
     if [[ $provider_type == "gcp" ]]; then
       gcp_pcf_terraform_template="c0-gcp-base"
       gcp_proj_id="google.com:pcf-demos"
       gcp_terraform_prefix="kryten"
       gcp_svc_acct_key='{}'
     fi
  else
     exec_mode_root="./gcp-concourse/json-opsman"
     if [[ -z ${pcf_opsman_admin} || -z ${pcf_opsman_admin} ]]; then
       echo "config-director-json_err: Missing Key Variables!!!!"
       exit 1
     fi
  fi

  json_file_path="${exec_mode_root}/${gcp_pcf_terraform_template}"
  opsman_host="opsman.${pcf_ert_domain}"


# Import reqd BASH functions

source ${exec_mode_root}/config-director-json-fn-opsman-curl.sh
source ${exec_mode_root}/config-director-json-fn-opsman-auth.sh
source ${exec_mode_root}/config-director-json-fn-opsman-json-to-post-data.sh
source ${exec_mode_root}/config-director-json-fn-opsman-extensions.sh
source ${exec_mode_root}/config-director-json-fn-opsman-config-director.sh



############################################################################################################
###### Create iaas_configuration JSON                                                                 ######
############################################################################################################

if [[ $provider_type == "gcp" ]]; then
  iaas_configuration_json=$(echo "{
    \"iaas_configuration[project]\": \"${gcp_proj_id}\",
    \"iaas_configuration[default_deployment_tag]\": \"${gcp_terraform_prefix}\",
    \"access_type\": \"keys\",
    \"iaas_configuration[auth_json]\":
      $(echo ${gcp_svc_acct_key})
  }")
else
  echo "config-director-json_err: Provider Type ${provider_type} not yet supported"
  exit 1
fi

############################################################################################################
############################################# Functions  ###################################################
############################################################################################################

  function fn_urlencode {
     local unencoded=${@}
     encoded=$(echo $unencoded | perl -pe's/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg')
     #opsman "=,&,\crlf"" fixes, calls fail with these strings encoded
     encoded=$(echo ${encoded} | sed s'/%3D/=/g')
     encoded=$(echo ${encoded} | sed s'/%26/\&/g')
     encoded=$(echo ${encoded} | sed s'/%0A//g')

     echo ${encoded} | tr -d '\n' | tr -d '\r'
  }

  function fn_err {
     echo "config-director-json_err: ${1:-"Unknown Error"}"
     exit 1
  }

  function fn_run {
     printf "%s " ${@}
     eval "${@}"
     printf " # [%3d]\n" ${?}
  }


############################################################################################################
############################################# Main Logic ###################################################
############################################################################################################

case $config_target in
  "director")
    echo "Starting $config_target config ...."
    fn_config_director
  ;;
  *)
    fn_err "$config_target not enabled"
  ;;
esac


############################################################################################################
#################################################  END  ####################################################
############################################################################################################
