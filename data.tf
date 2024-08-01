data "archive_file" "function_code" {
  type        = "zip"
  source_dir  = "${path.root}/../src"
  output_path = "${path.root}/function.zip"
}
