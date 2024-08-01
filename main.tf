provider "google" {
  project = var.project_id
  region  = var.location
}

resource "google_storage_bucket" "source_bucket" {
  name          = var.source_bucket_name
  location      = var.location
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  lifecycle {
    ignore_changes = [
      name,
      location,
      storage_class
    ]
  }
}




resource "google_storage_bucket" "destination_bucket" {
  name          = var.destination_bucket_name
  location      = var.location
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  lifecycle {
    ignore_changes = [
      name,
      location,
      storage_class
    ]
  }
}


resource "google_service_account" "function_service_account" {
  account_id   = var.service_account_name
  display_name = "Service account for Cloud Function"
}

resource "google_project_iam_member" "pubsub_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:service-378969527341@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "gcs_pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-378969527341@gs-project-accounts.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "member-role" {
  for_each = toset([
    "roles/eventarc.eventReceiver",
    "roles/run.invoker",
    "roles/pubsub.publisher",
    "roles/storage.objectUser",
  ])
  role    = each.key
  member  = "serviceAccount:${google_service_account.function_service_account.email}"
  project = var.project_id
}



resource "google_storage_bucket_object" "function_code" {
  name   = "function.zip"
  bucket = google_storage_bucket.util_bucket.name
  source = data.archive_file.function_code.output_path
}

resource "google_storage_bucket" "util_bucket" {
  name          = var.util_bucket_name
  location      = var.location
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  lifecycle {
    ignore_changes = [
      name,
      location,
      storage_class
    ]
  }
}

resource "google_cloudfunctions2_function" "function" {
  name        = "gcs-to-gcs-function"
  location    = var.location
  description = "A function triggered by GCS"

  build_config {
    runtime     = "python312"
    entry_point = "gcs_to_gcs"
    environment_variables = {
      PROJECT_ID = var.project_id

    }
    source {
      storage_source {
        bucket = google_storage_bucket.util_bucket.name
        object = google_storage_bucket_object.function_code.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    min_instance_count = 0
    available_memory   = "256M"
    timeout_seconds    = 60

    environment_variables = {
      PROJECT_ID = var.project_id

    }

    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.function_service_account.email
  }

  event_trigger {
    event_type            = "google.cloud.storage.object.v1.finalized"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.function_service_account.email
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.source_bucket.name
    }
  }

  depends_on = [google_service_account.function_service_account, google_project_iam_member.member-role]
}


resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.dataset_id
  location   = var.location 
}

resource "google_bigquery_table" "external_table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  landing_table_id   = var.landing_table_id

  external_data_configuration {
    source_uris = [var.gcs_bucket_uri_landing]

    csv_options {
      skip_leading_rows = 1
    }

    schema {
      field {
        name = "load_date"
        type = "DATE"
      }

      field {
        name = "load_time"
        type = "TIMESTAMP"
      }

      field {
        name = "file_name"
        type = "STRING"
      }
    }

    source_format = "CSV"
  }
}
