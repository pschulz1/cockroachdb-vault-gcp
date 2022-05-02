resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "PKI"
}

resource "vault_pki_secret_backend_role" "crdb_node" {
  backend         = vault_mount.pki.path
  name            = "crdb_node"
  allow_any_name  = true
  allow_localhost = true
}

resource "vault_pki_secret_backend_root_cert" "pki" {
  backend              = vault_mount.pki.path
  type                 = "internal"
  common_name          = "CRL Demo Root CA"
  ttl                  = "315360000"
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = "DEMO OU"
  organization         = "DEMO organization"
}

resource "vault_policy" "pki" {
  name   = "pki"
  policy = file("${path.module}/policies/pki.hcl")
}
