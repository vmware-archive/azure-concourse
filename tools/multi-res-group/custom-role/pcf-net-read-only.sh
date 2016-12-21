#!/bin/bash
# Will need to set the subscription ID in the role json AssignableScopes
azure role create --inputfile pcf-net-read-only.json
#azure role set --inputfile pcf-net-read-only.json

## Create Resgroup
#azure group create multi-res-grp-pcf -l eastus


## Create AD acct
#azure ad app create --name "PCF Admin For C0" \
#--password 'P1v0t4l!P1v0t4l!' --home-page "http://c0-pcf-admin" \
#--identifier-uris "http://c0-pcf-admin"


## Create Service Principal
#azure ad sp create --applicationId 9cc33042-bcbf-4b79-b1f1-729243d42615


## Assign Roles

#azure role assignment create --spn "http://c0-pcf-admin" \
#--roleName "PCF Network Read Only" --resource-group network-core

#azure role assignment create --spn "http://c0-pcf-admin" \
#--roleName "Contributor" --resource-group multi-res-grp-pcf
