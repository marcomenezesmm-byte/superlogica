data "aws_s3_bucket" "selected" {
  bucket = "s3testmarco"
}

output "arn" {
	value = data.aws_s3_bucket.selected.arn
}
