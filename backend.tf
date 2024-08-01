terraform {
 backend "gcs" {
    bucket = "tf_state_autoflowx"
    prefix = "moduleA/terraform/state"
 }
}
