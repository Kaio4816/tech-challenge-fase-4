resource "aws_iam_role_policy" "eks_node_app_messaging" {
  name = "${var.eks_cluster_name}-app-messaging"
  role = module.eks.node_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEvaluationEventsQueue"
        Effect = "Allow"
        Action = [
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = module.sqs.queue_arn
      },
      {
        Sid    = "AllowAnalyticsTableWrites"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:DescribeTable"
        ]
        Resource = module.dynamodb.table_arn
      }
    ]
  })
}
