terraform {
 backend "gcs" {
    bucket = "autoflox_util"
    prefix = "moduleA/terraform/state"
 }
}
