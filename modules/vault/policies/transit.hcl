path "transit/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
path "auth/token/renew" {
  capabilities = ["update"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/create" {
capabilities = ["create", "read", "update", "list"]
}