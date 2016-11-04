#!/bin/bash
set -e


if [ $arg_wipe == "wipe" ];
        then
                echo "Wiping Environment...."
        else
                echo "Need Args [0]=wipe, anything else and I swear I'll exit and do nothing!!! "
                echo "Example: ./wipe-env.sh wipe ..."
                exit 0
fi


#############################################################
#################### GCP Auth  & functions ##################
#############################################################
echo $gcp_svc_acct_key > /tmp/blah
gcloud auth activate-service-account --key-file /tmp/blah
rm -rf /tmp/blah

gcloud config set project $gcp_proj_id
gcloud config set compute/region $gcp_region


# Wipe all GCP Instances for given prefix within Zone ##MG Todo: Serial processing is slow,  look for a quicker way to wipe Instances
declare -a ZONE=(
$gcp_zone_1
$gcp_zone_2
$gcp_zone_3
)

for y in ${ZONE[@]}; do
	echo "----------------------------------------------------------------------------------------------"
  echo "Will delete all compute/instances objects with the prefix=$gcp_terraform_prefix in:"
	echo "project=$gcp_proj_id"
	echo "region=$gcp_region"
	echo "zone=$y"
	echo "----------------------------------------------------------------------------------------------"
  echo "Looking for bosh instance(s) first ...."
  echo "----------------------------------------------------------------------------------------------"
  BOSH_INSTANCE_CMD="gcloud compute instances list --flatten tags.items[] --format json | jq '.[] | select ((.tags.items == \"$gcp_terraform_prefix\" ) and (.metadata.items[].value == \"bosh\" and .metadata.items[].key == \"job\" )) | .name' | tr -d '\"' | sort -u"
  for i in $(eval $BOSH_INSTANCE_CMD);do
    echo "Deleting Instance:$i ..."
    gcloud compute instances delete $i --quiet --zone $y --delete-disks all
  done
  echo "----------------------------------------------------------------------------------------------"
  echo "Removed or Non Existant bosh instance(s)...."
  echo "----------------------------------------------------------------------------------------------"

  MY_CMD="gcloud compute instances list --flatten tags.items[] --format json | jq '.[] | select ((.tags.items == \"$gcp_terraform_prefix\" ) and (.zone == \"$y\")) | .name' | tr -d '\"'"
  echo $MY_CMD
  gcp_instances=""
  for i in $(eval $MY_CMD); do
  	 gcp_instances="$gcp_instances $i"
  done

  if [ -n "$gcp_instances" ]; then
      echo "|||Deleting Tagged Instances:$gcp_instances"
      echo "|||from zone $y ..."
      gcloud compute instances delete $gcp_instances --quiet --zone $y --delete-disks all
  fi

  MY_CMD="gcloud compute instances list | grep $gcp_terraform_prefix | grep $y | awk '{print\$1}'"
  echo $MY_CMD
  gcp_instances=""
  for i in $(eval $MY_CMD); do
     gcp_instances="$gcp_instances $i"
  done

  if [ -n "$gcp_instances" ]; then
      echo "|||Deleting Matching Prefix Instances:$gcp_instances"
      echo "|||from zone $y ..."
      gcloud compute instances delete $gcp_instances --quiet --zone $y --delete-disks all
  fi


	echo "=============================================================================================="
  echo "All compute/instances with the prefix or tag:$gcp_terraform_prefix in zone=$y have been wiped !!!"
	echo "=============================================================================================="
done


# Wipe Created network and all associated objects (routes,firewall-rules,forwarding-rules,subnets,networks,target-pools,etc...)
echo "Will delete all compute/networks objects with the prefix=$gcp_proj_id in zone=$gcp_zone_1"
declare -a COMPONENT=(
"firewall-rules"
"routes"
"forwarding-rules"
"subnets"
"networks"
"target-pools"
"addresses"
"target-http-proxies"
"target-https-proxies"
"url-maps"
"backend-services"
"http-health-checks"
"https-health-checks"
"managed-zones"
"ssl-certificates"
)

for z in ${COMPONENT[@]}; do
	echo "----------------------------------------------------------------------------------------------"
	echo "Will delete all $z objects with the prefix=$gcp_terraform_prefix in region=$gcp_region"
	echo "----------------------------------------------------------------------------------------------"

  #set gcloud command
  if [[ $z == "subnets" ]]; then
      z="compute networks $z"
  elif [[ $z == "managed-zones" ]]; then
      z="dns $z"
  else
      z="compute $z"
  fi

	for i in $(gcloud $z list  | grep $gcp_terraform_prefix | grep -v default | awk '{print $1}'); do
   echo "Deleting $z:$i ..."

   #special command args
   if [[ $z == "comuter networks subnets" ]]; then
		 	echo "|||Using gcloud cli beta function to delete subnet..."
	    gcloud beta $z delete $i --region $gcp_region --quiet
   elif [[ $z == "compute addresses" ]]; then
      tmp_region=$(gcloud $z list | grep $i | awk '{print$2}')
      if [[ ! $tmp_region == $gcp_region ]]; then
          echo "|||Removing global address $i..."
          gcloud $z delete $i --global --quiet
      else
          gcloud $z delete $i --region $gcp_region --quiet
      fi
    elif [[ $z == "compute forwarding-rules" ]]; then
       tmp_region=$(gcloud $z list | grep ^$i | awk '{print$2}')
       if [[ ! $tmp_region == $gcp_region ]]; then
           echo "|||Removing global forwarding-rules $i..."
           gcloud $z delete $i --global --quiet
       else
           gcloud $z delete $i --region $gcp_region --quiet
       fi
   elif [[ $z == "dns managed-zones" ]]; then
      touch /tmp/empty-file
      gcloud dns record-sets import -z "$i" --delete-all-existing /tmp/empty-file
      rm -rf /tmp/empty-file
      gcloud $z delete $i --quiet
   else
		 	gcloud $z delete $i --quiet
	 fi
  done
done
echo "=============================================================================================="
echo "All compute/networks objects with the prefix=$gcp_terraform_prefix in region=$gcp_region have been wiped !!!"
echo "=============================================================================================="

#Wipe Instance groups
for y in ${ZONE[@]}; do
  echo "----------------------------------------------------------------------------------------------"
  echo "Removing Instance Groups with the prefix or tag:$gcp_terraform_prefix in zone=$y...."
  echo "----------------------------------------------------------------------------------------------"

  declare -a INSTANCEGROUPS=(
  "managed"
  "unmanaged"
  )
  for i in  ${INSTANCEGROUPS[@]}; do

    for g in $(gcloud compute instance-groups $i list | grep $gcp_terraform_prefix | grep $y | awk '{print$1}'); do
      echo "|||Removing $i instance-group $g from zone $y ..."
      gcloud compute instance-groups $i delete $g --zone $y --quiet
    done

  done
done

#Wipe Buckets
for b in $(gsutil ls | grep $gcp_terraform_prefix); do
	echo "----------------------------------------------------------------------------------------------"
	echo "Will delete gcloud bucket $b with the prefix=$gcp_terraform_prefix"
	echo "----------------------------------------------------------------------------------------------"
  gsutil rb $b
done
echo "=============================================================================================="
echo "All buckets with the prefix=$gcp_terraform_prefix have been wiped"
echo "=============================================================================================="


#Wipe Images ,  this pretty much means we want a deicated project for now
echo "----------------------------------------------------------------------------------------------"
echo "Will delete all compute/images stemcell objects where project=$gcp_proj_id"
echo "----------------------------------------------------------------------------------------------"
  for x in $(gcloud compute images list | grep $gcp_proj_id | grep stemcell | awk '{print $1}'); do

  	 echo "Deleting Image:$x ..."
  	 gcloud compute images delete $x --quiet

  done
echo "=============================================================================================="
echo "All compute/images stemcell objects where project=$gcp_proj_id have been wiped !!!"
echo "=============================================================================================="



#################### Wipe End   ##########################
