resource "vault_mount" "gcp" {
  path        = "gcp"
  type        = "gcp"
  description = "GCP Secret Engine"
}

resource "google_service_account" "vault" {
  account_id   = "vault-service-account"
  display_name = "Vault Service Account"
}

resource "google_project_iam_member" "vault_project" {
  project = var.project_id
  role    = "roles/iam.serviceAccountKeyAdmin"
  member  = "serviceAccount:${google_service_account.vault.email}"
}

resource "google_service_account_key" "vault" {
  service_account_id = google_service_account.vault.name
}


resource "vault_gcp_auth_backend" "gcp" {
  credentials = base64decode(google_service_account_key.vault.private_key)
}

resource "vault_gcp_auth_backend_role" "gcp" {
  depends_on             = [vault_gcp_auth_backend.gcp]
  backend                = vault_mount.gcp.path
  type                   = "iam"
  bound_service_accounts = ["${var.service_account}"]
  role                   = "crdb"
  token_policies         = ["pki", "transit", "kv"]
}