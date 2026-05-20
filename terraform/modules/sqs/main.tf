resource "aws_sqs_queue" "sqs" {
  name                       = "${var.project_name}-${var.environment}-queue"
  delay_seconds              = 0
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600
}