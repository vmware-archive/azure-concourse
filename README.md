# Customer0 PCF+Azure Concourse Pipeline


*_Pipeline is currently experiencing turbulence due to updates,  should be resolved by EOD Dec 8, 2016 MG_*

### Pre_Reqs & Instructions for POC Deployment via Concourse

1. Create an Azure AD Service Principal for your subscription with "Contributor" Role on the target Azure Project

        azure ad app create --name "My SVC Acct" \
        --password 'P1v0t4l!P1v0t4l!' --home-page "http://MyBOSHAzureCPI" \
        --identifier-uris "http://MyBOSHAzureCPI"

        azure ad sp create --applicationId *!!![YOUR AD APP ID CREATED FROM PREVIOUS STEP]!!!*

        azure role assignment create --spn "http://MyBOSHAzureCPI" \
        --roleName "Contributor" --subscription *!!![YOUR SUBSCRIPTION ID]!!!*

2. `git clone` this repo

3. **EDIT!!!** `ci/c0-azure-concourse-poc-params.yml` and replace all variables/parameters you will want for your concourse individual pipeline run

4. **AFTER!!!** Completing Step 4 above ... log into concourse & create the pipeline.

  _(this command syntax assumes you are at the root of your repo)_
  - `fly -t [YOUR CONCOURSE TARGET] set-pipeline -p my-azure-pipeline -c ci/c0-azure-concourse-poc.yml -l ci/c0-azure-concourse-poc-params.yml`

5. Un-pause the pipeline

6. Run the **`init-env`** job manually,  you will need to review the output and record it for the DNS records that must then be made resolvable **BEFORE!!!** continuing to the next step:
  - Example:

```
==============================================================================================
This azure_pcf_terraform_template has an 'Init' set of terraform that has pre-created IPs...
==============================================================================================
info:    Executing command login
/info:    Added subscription CF-Customer 0                                     
info:    Setting subscription "CF-Customer 0" as default
+
info:    login command OK
You have now deployed Public IPs to azure that must be resolvable to:
----------------------------------------------------------------------------------------------
*.sys.azure.customer0.net == 137.117.56.166
*.cfapps.azure.customer0.net == 137.117.56.166
ssh.sys.azure.customer0.net == 137.117.56.166
doppler.sys.azure.customer0.net == 137.117.56.166
loggregator.sys.azure.customer0.net == 137.117.56.166
tcp.azure.customer0.net == 40.112.56.99
opsman.azure.customer0.net == 137.117.57.112
----------------------------------------------------------------------------------------------
DO Not Start the 'deploy-iaas' Concourse Job of this Pipeline until you have confirmed that DNS is reolving correctly.  Failure to do so will result in a FAIL!!!!
```

**[DEPLOY]**. **AFTER!!!** Completing Step 6 above ... Run the **`deploy-iaas`** job manually, if valid values were passed, a successful ERT deployment on Azure will be the result.
