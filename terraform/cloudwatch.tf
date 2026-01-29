resource "aws_cloudwatch_log_group" "log_group" {
  name              = local.cloudwatch_log_group_name
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-log-group"
  })
}

resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "${local.name_prefix}-unexpected-error-filter"
  log_group_name = aws_cloudwatch_log_group.log_group.name
  pattern        = "{ $.isUnexpectedError IS true }"

  metric_transformation {
    name      = "ErrorCount"
    namespace = "LogMetrics"
    value     = "1"
  }
}
