variable "project_id" {
    default = ""
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
    description = "ID is set on module call"
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
    default = ""
    description = "SSH user to be added to the instance"
}
variable "gce_ssh_pub_key_file" {
    default = ""
    description = "Path to SSH public key to be added into the instance"
}
variable "gce_ssh_priv_key_file" {
    default = ""
    description = "Path to SSH private key in order to connect to instances"
}
variable "org" {
    default = ""
    description = "CRDB Enterprise license org."
}
variable "license" {
    default = ""
    description = "CRDB Enterprise license"
}
variable "vault_version" {
    default = "1.9.0"
    description = "HashiCorp Vault Agent version to be downloaded"
}
variable "vault_addr" {
    default = ""
    description = "HashiCorp Vault address"
}