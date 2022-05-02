# Current not being used, as CRDB currently does not support the use of AES-GCM encryption keys
resource "vault_mount" "transit" {
  path        = "transit"
  type        = "transit"
  description = "Transit Secret Engine for EAR Keys"
}

resource "vault_policy" "transit" {
  name   = "transit"
  policy = file("${path.module}/policies/transit.hcl")
}

resource "vault_transit_secret_backend_key" "crdb_ear_key" {
  backend = "transit"
  name    = "crdb_ear"
  type = "aes256-gcm96"
  deletion_allowed = "true"
  exportable = true
}