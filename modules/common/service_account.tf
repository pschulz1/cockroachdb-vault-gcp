resource "google_service_account" "crdb" {
  account_id   = "crdb-service-account"
  display_name = "CRDB Service Account"
}

resource "google_project_iam_member" "crdb" {
  depends_on = [google_service_account.crdb]
  project    = var.project_id
  role       = "roles/iam.serviceAccountTokenCreator"
  member     = "serviceAccount:${google_service_account.crdb.email}"
}