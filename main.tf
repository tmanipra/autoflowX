provider "google" {
  project = var.project_id
  region  = var.location
}

resource "google_storage_bucket" "source_bucket" {
  name          = var.source_bucket_name
  location      = var.location
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
}


resource "google_storage_bucket" "util_bucket" {
  name          = var.util_bucket_name
  location      = var.location
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "destination_bucket" {
  name          = var.destination_bucket_name
  location      = var.location
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
}

resource "google_service_account" "function_service_account" {
  account_id   = var.service_account_name
  display_name = "Service account for Cloud Function"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.function_service_account.email}"
}

