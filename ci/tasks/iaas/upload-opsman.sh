#!/bin/bash
set -e

#############################################################
#################### GCP Auth  & functions ##################
#############################################################
echo $gcp_svc_acct_key > /tmp/blah
gcloud auth activate-service-account --key-file /tmp/blah
rm -rf /tmp/blah

gcloud config set project $gcp_proj_id
gcloud config set compute/region $gcp_region

### For GCP, grab the OpsManager image name from the Pivent PDF
echo "=============================================================================================="
echo "Getting GCP Ops Manager Image ...."
echo "=============================================================================================="

/usr/bin/pdftotext pivnet-opsmgr/*GCP*.pdf /tmp/opsman.txt
opsman_region="US"
pcf_opsman_image_tgz=$(grep -i -A 1 "$opsman_region:" /tmp/opsman.txt | grep release)
echo "Found GCP OpsMan Image @ $pcf_opsman_image_tgz ...."
pcf_opsman_image_name="opsman-"$(echo $pcf_opsman_image_tgz | awk -F "/" '{print$2}' | awk -F '.tar.gz' '{print$1}' | tr '.' "-")

echo $pcf_opsman_image_name > opsman-metadata/name

###test if image exists & if not then create it
if  [[ -z $(gcloud compute images list | grep $pcf_opsman_image_name) ]]; then
  echo "|||Opsman $pcf_opsman_image_name not found, creating it ...."
  gcloud compute images create $pcf_opsman_image_name --family pcf-opsman --source-uri "gs://$pcf_opsman_image_tgz"
else
  echo "|||Opsman $pcf_opsman_image_name found in current project ...."
fi
