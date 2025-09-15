resource "aws_glue_catalog_database" "db" {
  name = local.database_name
}

resource "aws_glue_job" "etl" {
  name              = "${local.name_prefix}-etl"
  role_arn          = aws_iam_role.glue_role.arn
  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"
  timeout           = 30
  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.artifacts.bucket}/${local.glue_scripts_key}"
  }
  default_arguments = {
    "--RAW_S3_PATH"    = "s3://${aws_s3_bucket.raw.bucket}/incoming/"
    "--OUTPUT_S3_PATH" = "s3://${aws_s3_bucket.processed.bucket}/curated/sales/"
    "--GLUE_DATABASE"  = local.database_name
    "--TEMP_DIR"       = "s3://${aws_s3_bucket.artifacts.bucket}/tmp/"
  }
}

resource "aws_glue_crawler" "processed" {
  name          = "${local.name_prefix}-processed-crawler"
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.db.name
  s3_target { path = "s3://${aws_s3_bucket.processed.bucket}/curated/sales/" }
}

resource "aws_glue_workflow" "wf" { name = "csv_pipeline" }

resource "aws_glue_trigger" "t0_start_job" {
  name          = "${local.name_prefix}-t0-start-job"
  type          = "ON_DEMAND"
  workflow_name = aws_glue_workflow.wf.name
  actions { job_name = aws_glue_job.etl.name }
}

resource "aws_glue_trigger" "t1_crawl_processed" {
  name          = "${local.name_prefix}-t1-crawl-processed"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.wf.name
  actions { crawler_name = aws_glue_crawler.processed.name }
  predicate {
    conditions {
      job_name = aws_glue_job.etl.name
      state    = "SUCCEEDED"
    }
  }
}
