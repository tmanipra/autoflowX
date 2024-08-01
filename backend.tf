terraform {
 backend "gcs" {
    bucket = "autoflowx_util"
    prefix = "moduleA/terraform/state"
 }
}
