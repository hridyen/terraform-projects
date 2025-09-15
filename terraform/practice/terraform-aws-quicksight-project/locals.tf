resource "random_id" "suffix" { byte_length = 3 }

locals {
  name_prefix        = "${var.project}-${var.env}-${random_id.suffix.hex}"
  raw_bucket_name    = "${local.name_prefix}-raw"
  processed_name     = "${local.name_prefix}-processed"
  artifacts_name     = "${local.name_prefix}-artifacts"
  athena_results_key = "athena-results/"
  glue_scripts_key   = "scripts/etl_job.py"
  database_name      = "data_viz_db"
}
