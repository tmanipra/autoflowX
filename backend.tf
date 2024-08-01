terraform {
 backend "gcs" {
    bucket = "terrafom-state-files"
    prefix = "moduleA/terraform/state"
 }
}
