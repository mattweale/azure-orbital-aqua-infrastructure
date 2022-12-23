# **Azure Orbital - Infrastructure for Level 0 and Level 1 Processing of AQUA EOS Satellite Data**

# Contents

[Overview](#overview)

[Deployment](#deployment)

[Explore and Verify](#Explore-and-Verify)

[Example Output](#Example-Output)

[Backlog](#backlog)

# Overview

In this scenario we will be collecting raw instrument data from a NASA Earth Observation Satellite, AQUA. It is named Aqua, Latin for water, because of the large amount of information that the mission is collecting about the Earth's water cycle, including evaporation from the oceans, water vapor in the atmosphere, clouds, precipitation, soil moisture, sea ice, land ice, and snow cover on the land and ice. Additional variables also being measured by Aqua include radiative energy fluxes, aerosols, vegetation cover on the land, phytoplankton and dissolved organic matter in the oceans, and air, land, and water temperatures.

This Terraform deploys the downstream infrastructure components required to process raw instrument data from AQUA, a NASA Earth Observation Satellite using the Azure Orbital Ground Station (AOGS). This builds on the Azure Orbital Integraton TCP to Blob Component to provide the self-start capability to build the infrastructure required to receive data from the ground station and process across virtual machine compute capability.

It is assumed that you have already registered the AQUA Spacecraft:

* Registered a Spacecraft [documentation](https://docs.microsoft.com/en-us/azure/orbital/register-spacecraft)

You should be familiar with:

* Creating a Contact Profile [documentation](https://docs.microsoft.com/en-us/azure/orbital/contact-profile)
* Scheduled a Contact [documentation](https://docs.microsoft.com/en-us/azure/orbital/schedule-contact)

A Contact Profile, storing the link details from Aqua with the Ingress Loadbalancer Endpoint IP, is created as part of the TCP to Blob deployment.

TCP to BLOB is a kubernetes service that provides a TCP endpoint to receive Azure Orbital Ground Station (AOGS) satellite downlink data and persists it in Azure BLOB Storage. TCP to Blob can be deployed from here:

* TCP to Blob [documentation](https://github.com/Azure/azure-orbital-integration/tree/main/tcp-to-blob)

Once both TCP to Blob and this Terraform have been deployed the following

A [single] Hub vNET is deployed with 5 Subnets:

* AzureBastionSubnet: Subnet for Bastion.
* vnet-subnet: Subnet for AKS Nodes.
* pod-subnet: Subnet for AKS Pods.
* orbital-subnet: Delegated Subnet for the Orbital Service.
* aqua-tools-subnet: Subnet for hosting Virtual Machines for Aqua raw data processing.

2 Virtual Machines have been deployed into the aqua-tools-subnet each having been configured using a Custom Script Extension to download and execute scripts for post-deployment configuration and software installation of the components needed:

* vm-orbital-rt-stps - RT-STPS VM: The Real-time Software Telemetry Processing System [RT-STPS v7.0] ingests unsynchronized downlink data telemetry to various formats for further processing.
* vm-orbital-ipopp - International Planetary Observation Processing Package [IPOPP v4.1 Patch2] processes science data and derivative products [from AQUA and other missions] using Science Processing Algorithms [SPA]

NASA's Earth Observing System Data and Information System (EOSDIS) data products are processed at various levels ranging from Level 0 to Level 4. Level 0 products are raw data at full instrument resolution. At higher levels, the data are converted into more useful parameters and formats.

Some useful documentation:

Azure Orbital [documentation](https://docs.microsoft.com/en-us/azure/orbital/) <br>
NASA AQUA Mission [documentation](https://aqua.nasa.gov/) <br>
NASA Direct Readout Labratory [DRL] [documentation](https://directreadout.sci.gsfc.nasa.gov/) <br>
NASA Real-time Software Telemetry Processing System [RT-STPS] [documentation](https://directreadout.sci.gsfc.nasa.gov/?id=dspContent&cid=69) <br>
NASA International Planetary Observation Processing Package [IPOPP] [documentation](https://directreadout.sci.gsfc.nasa.gov/?id=dspContent&cid=68) <br>
NASA Data Processing Levels [documentation](https://www.earthdata.nasa.gov/engage/open-data-services-and-software/data-information-policy/data-levels#:~:text=Level%200%20products%20are%20raw,many%20have%20Level%204%20SDPs.) <br>
NORAD TRE Empemeris [documentation](https://aqua.nasa.gov/) <br>

Once deployed it should look like this: <br>
<br>
<br>
![image](images/azure_aqua_processing.png)
<br>
<br>
Note that this stores state locally so a [Terraform] backend block will need to be added if required.

# Deployment

Pre-requisites:

* This assumes that you have configured Terraform to use a Service Principal for Deployment, with appropriate permissions in the target Subscription:

  Azure Terraform Service Principal [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#configuring-the-service-principal-in-terraform) <br>

  `# Create Service Principal`<br>
  `az ad sp create-for-rbac --name mytfsp`

* Use GitHub Encrypted Secrets to store sensitive information, in this case the Service Principal ID and SECRET:

  GitHub Encrypted Secrets [documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets) <br>

  `# Add the following four secrets`<br>
  `ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000`<br>
  `ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000`<br>
  `ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000`<br>
  `ARM_TENANT_ID="00000000-0000-0000-0000-000000000000`<br>

* Terraform uses a state file to manage the state of the resources deployed. In this deployment we will store the state file remotely in Azure; specficically in a Storage Account Container called: terraformstate. We first need to create those resources:<br>

  `# Create Resource Group`<br>
  `az group create -n <rg-name> -l uksouth`<br>
  <br>
  `# Create Storage Account [Storage Account name needs to be globally unique]`<br>
  `az storage account create -n <sa-name> -g <rg-name> -l uksouth --sku Standard_LRS`<br>
  <br>
  `# Create Storage Account Container`<br>
  `az storage container create -n terraformstate --account-name <sa-name>`<br><br>

The Backend Block tells Terraform where to store the state. This is where the .tfstate file will be stored. Update this block with the detals of the Resource Group, Storage Account and Container Name you have created. The Key is the name of the Blob, in the Container, that is the state file.<br>
<br>
![image](images/backend_block.png)
<br>

* This deployment also assumes that you have downloaded the required software from the NASA DRL and stored in a separate Storage Account with a Container for RT-STPS and IPOPP as below:<br>

  `https://[storageaccountname].blob.core.windows.net/rt-stps`<br>
  `/RT-STPS_7.0.tar.gz`<br>
  `/RT-STPS_7.0_testdata.tar.gz`<br>
  <br>
 `https://[storageaccountname].blob.core.windows.net/ipopp`<br>
  `/DRL-IPOPP_4.1.tar.gz`<br>
  `/DRL-IPOPP_4.1_PATCH_1.tar.gz`<br>
  `/DRL-IPOPP_4.1_PATCH_2.tar.gz`<br>
  <br>

A Managed Identity is created and assigned the RBAC Role of Storage Blob Data Contributor to the Storage Account that you create to store the NASA Software. This Managed Identity is attached to both the RT-STPS and IPOPP Virtual Machines that allows them to pull the software during the execution of Custom Script Extensionn. All you need do is update the GitHub Secret [AZURE_AQUA_STORAGE_ACCOUNT] with the name of your Storage Account.

Note that the Storage Account [saorbital99.blob.core.windows.net] and Event Hub Namespace [orbital.eh.namespace.servicebus.windows.net] URL have to be globally unique so you MAY need to change their name in the appropriate terraform file [storageaccount.tf and eventhub.tf].

Deployment takes approximately 45 minutes, the vasy majority of this being the installation of IPOPP.

Once deployed you need to update the Orbital Contact Profile with the IP Address of the Endpoint [VM] to which Orbital streams the payload, making note of the port. You also need to update the demodulationConfiguration, replacing X.X.X.X with the IP Address of your Endpoint. The demodulationConfiguration Key:Value value is [here](./json/demodulationConfiguration.txt).<br>
<br>
<br>
![image](images/azure_orbital_contact_profile.png)
<br>
<br>
Once the Contact Profile has been updated, make sure that the Satellite Ephemeris is current and then schedule a Contact.

# Explore and Verify

After the Terraform deployment concludes successfully, the following has been deployed into your subscription:

* A resource group named **rg-orbital** containing:
* One vNET containing three subnets, AzureBastionSubnet, services-subnet and endpoint-subnet;
* Three VMs, vm-orbital-data-collection, vm-orbital-rt-stps and vm-orbital-ipopp;
* Data disk [256GB] attached and mounted to each VM at /datadrive;
* A Storage Account **saorbital** with Containers raw-data, rt-stps, ipopp and shared;
* Container [saorbital99/shared] NFS Mounted to each VM at /nfsdata;
* An NSG attached to the endpoint-subnet with Inbound Traffic Allowed for 22, 3389 and 50001;

# Example Output

An example of the output that can be produced can be seen in the image below, a composite of a number of GEOTIFF's, displaying the Aqua Moderate Resolution Imaging Spectroradiometer (MODIS) NASA Level-2 (L2) Cloud Mask. The nominal spatial resolution of the Aqua MODIS L2 Cloud Mask is 1 km.
<br>
<br>
![image](images/geotiff_output.png)
<br>
<br>

# Backlog

A number of things need to be improved.......

* Use fstab for making mounts permanent
* Query the GitHub actions runner's public IP addresses to dynamically build the whitelist for the Storage Firewall
* Allow Storage Account name and Event Hub Namespace Name to be passed via a GitHub Secret
* More elegant shell scripts all round :see_no_evil:
