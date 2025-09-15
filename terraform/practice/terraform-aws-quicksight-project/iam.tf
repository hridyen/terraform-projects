resource "aws_iam_role" "glue_role" {
  name = "${local.name_prefix}-glue-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "glue.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_extra" {
  name = "${local.name_prefix}-glue-extra"
  role = aws_iam_role.glue_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket", "s3:GetObject", "s3:PutObject", "s3:DeleteObject"
        ],
        Resource = [
          aws_s3_bucket.raw.arn, aws_s3_bucket.processed.arn, aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.raw.arn}/*", "${aws_s3_bucket.processed.arn}/*", "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "glue:*", "athena:*",
          "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}
