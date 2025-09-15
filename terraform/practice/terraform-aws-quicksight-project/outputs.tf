output "raw_bucket" { value = aws_s3_bucket.raw.bucket }
output "processed_bucket" { value = aws_s3_bucket.processed.bucket }
output "artifacts_bucket" { value = aws_s3_bucket.artifacts.bucket }
output "glue_job_name" { value = aws_glue_job.etl.name }
output "glue_processed_crawler" { value = aws_glue_crawler.processed.name }
output "glue_workflow" { value = aws_glue_workflow.wf.name }
output "athena_workgroup" { value = aws_athena_workgroup.wg.name }
output "database_name" { value = aws_glue_catalog_database.db.name }
