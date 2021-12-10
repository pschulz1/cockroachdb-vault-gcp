## ABOUT
This module is inntented as an example of how a self-hosted CockroachDB cluster could be provisioned on GCP and integrated with HashiCorp Vault.
The module is fairly self-contained and only reauires an external HashiCorp Vault to be available. All the Vault related configuration is part of the module. 

# Architecture
<Graphic TBD>

# Prereqs.
1. gcloud - Having gcloud installed and being authenticated on the machine which will execute the Terraform configuration. Otherwise you will need to modify the provider.tf and feed your secrets to the GCP provider ressource. 
2. HashiCorp Vault - Certificates in this module will be generated and sourced from HashiCorp Vault. Your GCP instances will need to be able to communicate to Vault. Recommendation: Spin up a HCP "dev" cluster. A module for that can be found here: https://github.com/pschulz1/HCP-Vault-Dev
3. SSH key pair - For now this is external to the module. 

openssl genrsa -out key.pem 2048<br/>
openssl rsa -in key.pem -outform PEM -pubout -out public.pem

# Tunables
The following Terraform variables *must* be set in order to ensure functionality of the module

* project_id - GCP Project ID
* crdb_version - Desired CockroachDB Version
* gce_ssh_user - SSH user to be confired inside the instances
* gce_ssh_pub_key_file - Path to SSH cert file (added to the GCP instances OS)
* gce_ssh_priv_key_file - Path to SSH key file (used to connect to the instance)
* org - CockroachDB og in the license
* license - CockroachDB Enterprise license
* vault_version - Desired CockroachDB Version
* vault_addr - External HCP Vault address

# Usage

1. Install gcloud and authenticate via "gcloud auth application-default login" 
2. Obtain token and vault address from target HCP Vault cluster
3. export VAULT_ADDR=<public or internally on GCP available >
   export VAULT_TOKEN=<TOKEN>
4. terraform init
5. terraform apply -auto-approve
