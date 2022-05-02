variable "project_id" {
    default = "patrick-schulz-332212"
    description = "GCP project ID"
}
variable "machine_type" {
    default = "e2-medium"
    description = "Size of the GCP instance"
}
variable "zone" {
    default = ""
    description = "GCP zone - No need to change it here"
}
variable "region" {
    default = "us-east4"
    description = "GCP region"
}
variable "crdb_version" {
    default = "v21.2.0"
    description = "Required CRDB version to be downloaded upon setup"
}
variable "node_id" {
    default = ""
    description = "Will be used to as part of the host naming"
}
variable "network" {
    default = ""
    description = "New GCP network inside the given GCP project"
}
variable "subnetwork" {
    default = ""
    description = "Subnetwork to place instances into"
}
variable "service_account" {
    default = "crdb-service-account"
}
variable "gce_ssh_user" {
    default = "patrick"
    description = "SSH user to be added to the instance"
}
variable "gce_ssh_pub_key_file" {
    default = "/Users/patrick/.ssh/gce_public_key.pub"
    description = "Path to SSH public key to be added into the instance"
}
variable "gce_ssh_priv_key_file" {
    default = "/Users/patrick/.ssh/gce_private_key.pem"
    description = "Path to SSH private key in order to connect to instances"
}
variable "org" {
    default = "PatrickSchulz"
    description = "CRDB Enterprise license org."
}
variable "license" {
    default = "crl-0-EPC5w44GGAIiDVBhdHJpY2tTY2h1bHo"
    description = "CRDB Enterprise license"
}
variable "vault_version" {
    default = "1.9.0"
    description = "HashiCorp Vault Agent version to be downloaded"
}
variable "vault_addr" {
    default = "https://crdb.vault.11eb0fea-f619-3fcf-8aa6-0242ac110005.aws.hashicorp.cloud:8200"
    description = "HashiCorp Vault address"
}