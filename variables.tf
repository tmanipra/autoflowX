variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "source_bucket_name" {
  description = "The name of the source GCS bucket"
  type        = string
}

variable "util_bucket_name" {
  description = "The name the utility GCS bucket"
  type        = string
}

variable "destination_bucket_name" {
  description = "The name of the destination GCS bucket"
  type        = string
}

variable "location" {
  description = "The location of the GCS bucket"
  type        = string
}

variable "function_name" {
  description = "The name of the Cloud Function"
  type        = string
}

variable "service_account_name" {
  description = "The name of the service account"
  type        = string
}

variable "dataset_id" {
  description = "The ID of the BigQuery dataset"
  type        = string
}

variable "table_id" {
  description = "The ID of the BigQuery table"
  type        = string
}

variable "gcs_bucket_uri" {
  description = "The URI of the GCS bucket containing the CSV files"
  type        = string
}
