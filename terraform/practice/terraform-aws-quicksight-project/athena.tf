resource "aws_athena_workgroup" "wg" {
  name = "DataVizWG"
  configuration {
    enforce_workgroup_configuration = true
    result_configuration { output_location = "s3://${aws_s3_bucket.artifacts.bucket}/athena-results/" }
  }
}

resource "aws_athena_named_query" "sample" {
  name      = "Sample Select"
  workgroup = aws_athena_workgroup.wg.name
  database  = aws_glue_catalog_database.db.name
  query     = "SELECT * FROM sales_parquet LIMIT 20;"
}
