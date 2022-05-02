resource "vault_mount" "kv" {
  path        = "secret"
  type        = "kv-v2"
  description = "Key Value Store"
}

resource "vault_generic_secret" "crdb" {
  depends_on = [vault_mount.kv]
  path       = "secret/crdb/"

  data_json = <<EOT
{
  "encryption_key":   "tbd"
}
EOT
}

resource "vault_policy" "kv" {
  name   = "kv"
  policy = file("${path.module}/policies/kv.hcl")
}
