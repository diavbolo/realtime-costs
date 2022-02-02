
resource "aws_cloudwatch_metric_alarm" "mwaa_dag_errors" {
  alarm_name          = "${var.project_name}-mwaa-dag-errors"
  metric_name         = aws_cloudwatch_log_metric_filter.mwaa_dag_exceptions.name
  threshold           = "0"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "2"
  period              = "60"
  namespace           = "ImportantMetrics"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.sns_alert.arn]
}

resource "aws_cloudwatch_log_metric_filter" "mwaa_dag_exceptions" {
  name           = "exceptions"
  log_group_name = "airflow-${var.project_name}-airflow-Task"
  pattern        = "exceptions"

  metric_transformation {
    name      = "exceptions"
    namespace = "ImportantMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_dashboard" "others" {
  dashboard_name = "${var.project_name}-others"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 1,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AmazonMWAA", "ImportErrors", "Function", "DAG Processing", "Environment", "${local.airflow_name}" ]
                ],
                "region": "${var.region}"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 7,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AmazonMWAA", "TaskInstanceFailures", "Task", "All", "Environment", "${local.airflow_name}", "DAG", "All" ]
                ],
                "region": "${var.region}"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 0,
            "width": 6,
            "height": 1,
            "properties": {
                "markdown": "## **MWAA: ${local.airflow_name}**"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 1,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${local.mysql_name}" ]
                ],
                "region": "${var.region}"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 13,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/RDS", "WriteIOPS", "DBInstanceIdentifier", "${local.mysql_name}" ]
                ],
                "region": "${var.region}"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 19,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", "${local.mysql_name}" ]
                ],
                "region": "${var.region}"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 7,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "${local.mysql_name}" ]
                ],
                "region": "${var.region}"
            }
        },
        {
            "type": "text",
            "x": 6,
            "y": 0,
            "width": 6,
            "height": 1,
            "properties": {
                "markdown": "## **RDS: ${local.mysql_name}**"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 1,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ES", "2xx", "DomainName", "${local.es_name}", "ClientId", "${data.aws_caller_identity.current.account_id}" ],
                    [ ".", "3xx", ".", ".", ".", "." ],
                    [ ".", "4xx", ".", ".", ".", "." ],
                    [ ".", "5xx", ".", ".", ".", "." ]
                ],
                "region": "${var.region}"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 7,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ES", "AlertingIndexStatus.green", "DomainName", "${local.es_name}", "ClientId", "${data.aws_caller_identity.current.account_id}", { "color": "#2ca02c" } ],
                    [ ".", "AlertingIndexStatus.red", ".", ".", ".", ".", { "color": "#d62728" } ],
                    [ ".", "AlertingIndexStatus.yellow", ".", ".", ".", ".", { "color": "#ffbb78" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "stat": "Average",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 13,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ES", "CPUUtilization", "DomainName", "${local.es_name}", "ClientId", "${data.aws_caller_identity.current.account_id}" ]
                ],
                "region": "${var.region}"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 19,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ES", "FreeStorageSpace", "DomainName", "${local.es_name}", "ClientId", "${data.aws_caller_identity.current.account_id}" ]
                ],
                "region": "${var.region}"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 31,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ES", "WriteIOPS", "DomainName", "${local.es_name}", "ClientId", "${data.aws_caller_identity.current.account_id}" ]
                ],
                "region": "${var.region}"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 25,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ES", "ReadIOPS", "DomainName", "${local.es_name}", "ClientId", "${data.aws_caller_identity.current.account_id}" ]
                ],
                "region": "${var.region}"
            }
        },
        {
            "type": "text",
            "x": 12,
            "y": 0,
            "width": 6,
            "height": 1,
            "properties": {
                "markdown": "## **OpenSearch: ${local.es_name}**"
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 1,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ApiGateway", "4XXError", "ApiName", "${local.lambda_name}", "Stage", "prod" ],
                    [ ".", "5XXError", ".", ".", ".", "." ]
                ],
                "region": "${var.region}"
            }
        },
        {
            "type": "text",
            "x": 18,
            "y": 0,
            "width": 6,
            "height": 1,
            "properties": {
                "markdown": "## **API Gateway: ${local.lambda_name}**"
            }
        }
    ]
}
EOF
}

resource "aws_cloudwatch_dashboard" "kinesis" {
  dashboard_name = "${var.project_name}-kinesis"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "height": 5,
            "width": 6,
            "y": 41,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ { "expression": "2 *\n                2097152 * PERIOD(m0) * IF(m0, 1, 1)", "label": "Maximum get records Limit", "id": "e0", "color": "#d62728", "period": 60 } ],
                    [ "AWS/Kinesis", "GetRecords.Bytes", "StreamName", "${local.kinesis_ec2_name}", { "id": "m0", "visible": true } ]
                ],
                "stat": "Sum",
                "title": "Get records - sum (Bytes)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 36,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/Kinesis", "GetRecords.IteratorAgeMilliseconds", "StreamName", "${local.kinesis_ec2_name}", { "id": "m1", "visible": true } ]
                ],
                "stat": "Maximum",
                "title": "Get records iterator age - maximum (Milliseconds)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 46,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/Kinesis", "GetRecords.Latency", "StreamName", "${local.kinesis_ec2_name}", { "id": "m2", "visible": true } ]
                ],
                "stat": "Average",
                "title": "Get records latency - average (Milliseconds)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 31,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/Kinesis", "GetRecords.Records", "StreamName", "${local.kinesis_ec2_name}", { "id": "m3", "visible": true } ]
                ],
                "stat": "Sum",
                "title": "Get records - sum (Count)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 51,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/Kinesis", "GetRecords.Success", "StreamName", "${local.kinesis_ec2_name}", { "id": "m4", "visible": true } ]
                ],
                "stat": "Average",
                "title": "Get records success - average (Percent)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 1,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ { "expression": "2 *\n                1048576 * PERIOD(m5) * IF(m5, 1, 1)", "label": "Incoming data Limit", "id": "e5", "color": "#d62728", "period": 60 } ],
                    [ "AWS/Kinesis", "IncomingBytes", "StreamName", "${local.kinesis_ec2_name}", { "id": "m5", "visible": true } ]
                ],
                "stat": "Sum",
                "title": "Incoming data - sum (Bytes)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 6,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ { "expression": "2 *\n                1000 * PERIOD(m6) * IF(m6, 1, 1)", "label": "Incoming records Limit", "id": "e6", "color": "#d62728", "period": 60 } ],
                    [ "AWS/Kinesis", "IncomingRecords", "StreamName", "${local.kinesis_ec2_name}", { "id": "m6", "visible": true } ]
                ],
                "stat": "Sum",
                "title": "Incoming data - sum (Count)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 11,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/Kinesis", "PutRecord.Bytes", "StreamName", "${local.kinesis_ec2_name}", { "id": "m7", "visible": true } ]
                ],
                "stat": "Sum",
                "title": "Put record - sum (Bytes)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 21,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/Kinesis", "PutRecord.Latency", "StreamName", "${local.kinesis_ec2_name}", { "id": "m8", "visible": true } ]
                ],
                "stat": "Average",
                "title": "Put record latency - average (Milliseconds)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 26,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/Kinesis", "PutRecord.Success", "StreamName", "${local.kinesis_ec2_name}", { "id": "m9", "visible": true } ]
                ],
                "stat": "Average",
                "title": "Put record success - average (Percent)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 56,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/Kinesis", "ReadProvisionedThroughputExceeded", "StreamName", "${local.kinesis_ec2_name}", { "id": "m12", "visible": true } ]
                ],
                "stat": "Average",
                "title": "Read throughput exceeded - average (Percent)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 16,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/Kinesis", "WriteProvisionedThroughputExceeded", "StreamName", "${local.kinesis_ec2_name}", { "id": "m13", "visible": true } ]
                ],
                "stat": "Average",
                "title": "Write throughput exceeded - average (Count)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 1,
            "x": 6,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ { "expression": "4 *\n                1048576 * PERIOD(m5) * IF(m5, 1, 1)", "label": "Incoming data Limit", "id": "e5", "color": "#d62728", "period": 60 } ],
                    [ "AWS/Kinesis", "IncomingBytes", "StreamName", "${local.kinesis_ec2_enriched_name}", { "id": "m5", "visible": true } ]
                ],
                "stat": "Sum",
                "title": "Incoming data - sum (Bytes)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 6,
            "x": 6,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ { "expression": "4 *\n                1000 * PERIOD(m6) * IF(m6, 1, 1)", "label": "Incoming records Limit", "id": "e6", "color": "#d62728", "period": 60 } ],
                    [ "AWS/Kinesis", "IncomingRecords", "StreamName", "${local.kinesis_ec2_enriched_name}", { "id": "m6", "visible": true } ]
                ],
                "stat": "Sum",
                "title": "Incoming data - sum (Count)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 11,
            "x": 6,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/Kinesis", "PutRecords.Bytes", "StreamName", "${local.kinesis_ec2_enriched_name}", { "id": "m10", "visible": true } ]
                ],
                "stat": "Sum",
                "title": "Put records - sum (Bytes)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 21,
            "x": 6,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/Kinesis", "PutRecords.Latency", "StreamName", "${local.kinesis_ec2_enriched_name}", { "id": "m11", "visible": true } ]
                ],
                "stat": "Average",
                "title": "Put records latency - average (Milliseconds)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 16,
            "x": 6,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/Kinesis", "WriteProvisionedThroughputExceeded", "StreamName", "${local.kinesis_ec2_enriched_name}", { "id": "m13", "visible": true } ]
                ],
                "stat": "Average",
                "title": "Write throughput exceeded - average (Count)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 31,
            "x": 6,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ { "expression": "(m11/m12) * 100", "id": "e1", "period": 60, "label": "Put records successful records - average (Percent)" } ],
                    [ "AWS/Kinesis", "PutRecords.SuccessfulRecords", "StreamName", "${local.kinesis_ec2_enriched_name}", { "id": "m11", "visible": false } ],
                    [ ".", "PutRecords.TotalRecords", ".", ".", { "id": "m12", "visible": false } ]
                ],
                "title": "Put records successful records - average (Percent)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 26,
            "x": 6,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ { "expression": "(m13/m12) * 100", "id": "e2", "period": 60, "label": "Put records failed records - average (Percent)" } ],
                    [ "AWS/Kinesis", "PutRecords.FailedRecords", "StreamName", "${local.kinesis_ec2_enriched_name}", { "id": "m13", "visible": false } ],
                    [ ".", "PutRecords.TotalRecords", ".", ".", { "id": "m12", "visible": false } ]
                ],
                "title": "Put records failed records - average (Percent)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 36,
            "x": 6,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ { "expression": "(m15/m12) * 100", "id": "e3", "period": 60, "label": "Put records throttled records - average (Percent)" } ],
                    [ "AWS/Kinesis", "PutRecords.ThrottledRecords", "StreamName", "${local.kinesis_ec2_enriched_name}", { "id": "m15", "visible": false } ],
                    [ ".", "PutRecords.TotalRecords", ".", ".", { "id": "m12", "visible": false } ]
                ],
                "title": "Put records throttled records - average (Percent)"
            }
        },
        {
            "height": 1,
            "width": 6,
            "y": 0,
            "x": 6,
            "type": "text",
            "properties": {
                "markdown": "### **Kinesis Stream: ${local.kinesis_ec2_enriched_name}**"
            }
        },
        {
            "height": 1,
            "width": 6,
            "y": 0,
            "x": 0,
            "type": "text",
            "properties": {
                "markdown": "### **Kinesis Stream: ${local.kinesis_ec2_name}**"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 1,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "DataReadFromKinesisStream.Records", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Sum",
                "title": "Records read from Kinesis Data Streams (Sum)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 16,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "DataReadFromKinesisStream.Bytes", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Sum",
                "title": "Bytes read from Kinesis Data Streams (Sum)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 6,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "ThrottledGetShardIterator", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Average",
                "title": "GetShardIterator operations throttled (Average)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 11,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "ThrottledGetRecords", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Average",
                "title": "GetRecords operations throttled (Average)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 51,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "SucceedConversion.Records", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Sum",
                "title": "Records successfully converted using AWS Glue (Sum)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 56,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "SucceedConversion.Bytes", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Sum",
                "title": "Bytes successfully converted using AWS Glue (Sum)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 61,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "FailedConversion.Records", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Sum",
                "title": "Records not successfully converted using AWS Glue (Sum)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 66,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "FailedConversion.Bytes", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Sum",
                "title": "Bytes not successfully converted using AWS Glue (Sum)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 21,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "JQProcessing.Duration", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Average",
                "title": "JQ Processing Duration"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 46,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "PartitionCount", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Maximum",
                "title": "Partition Count"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 76,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "PartitionCountExceeded", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Maximum",
                "title": "Partition Count Exceeded"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 26,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "PerPartitionThroughput", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Maximum",
                "title": "Per Partition Throughput"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 41,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "DeliveryToS3.ObjectCount", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Sum",
                "title": "Delivery To S3 Object Count"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 81,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "expression": "METRICS(\"m1\") * 100", "id": "e1" } ],
                    [ "AWS/Firehose", "DeliveryToS3.Success", "DeliveryStreamName", "${local.kinesis_ec2_name}", { "id": "m1", "visible": false } ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Average",
                "title": "Delivery to Amazon S3 success",
                "period": 300,
                "yAxis": {
                    "left": {
                        "showUnits": false,
                        "label": "Percentage",
                        "min": 0,
                        "max": 100
                    }
                }
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 31,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "DeliveryToS3.DataFreshness", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Maximum",
                "title": "Delivery to Amazon S3 data freshness (Maximum)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 36,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "DeliveryToS3.Records", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Sum",
                "title": "Records delivered to Amazon S3 (Sum)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 71,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/Firehose", "DeliveryToS3.Bytes", "DeliveryStreamName", "${local.kinesis_ec2_name}" ]
                ],
                "region": "${var.region}",
                "view": "timeSeries",
                "stacked": false,
                "stat": "Sum",
                "title": "Bytes delivered to Amazon S3 (Sum)"
            }
        },
        {
            "height": 1,
            "width": 6,
            "y": 0,
            "x": 12,
            "type": "text",
            "properties": {
                "markdown": "### **Kinesis Firehose: ${local.kinesis_ec2_name}**"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 1,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/KinesisAnalytics", "KPUs-Interactive", "Application", "${local.kinesis_studio_name}" ]
                ],
                "stat": "Average",
                "title": "KPUs (Count)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 6,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/KinesisAnalytics", "cpuUtilization", "Application", "${local.kinesis_studio_name}" ]
                ],
                "stat": "Average",
                "title": "Apache Flink CPU usage (Percentage)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 21,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/KinesisAnalytics", "heapMemoryUtilization", "Application", "${local.kinesis_studio_name}" ]
                ],
                "stat": "Average",
                "title": "Apache Flink heap memory usage (Percentage)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 51,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/KinesisAnalytics", "oldGenerationGCTime", "Application", "${local.kinesis_studio_name}" ]
                ],
                "stat": "Average",
                "title": "Apache Flink time spent on old garbage collection (Milliseconds)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 11,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/KinesisAnalytics", "oldGenerationGCCount", "Application", "${local.kinesis_studio_name}" ]
                ],
                "stat": "Average",
                "title": "Apache Flink old garbage collection operations (Count)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 41,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/KinesisAnalytics", "threadsCount", "Application", "${local.kinesis_studio_name}" ]
                ],
                "stat": "Average",
                "title": "Apache Flink thread count (Count)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 16,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/KinesisAnalytics", "zeppelinCpuUtilization", "Application", "${local.kinesis_studio_name}" ]
                ],
                "stat": "Average",
                "title": "Apache Zeppelin CPU usage (Percentage)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 26,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/KinesisAnalytics", "zeppelinHeapMemoryUtilization", "Application", "${local.kinesis_studio_name}" ]
                ],
                "stat": "Average",
                "title": "Apache Zeppelin heap memory usage (Bytes)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 46,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/KinesisAnalytics", "zeppelinServerUptime", "Application", "${local.kinesis_studio_name}" ]
                ],
                "stat": "Average",
                "title": "Apache Zeppelin server uptime (Seconds)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 31,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/KinesisAnalytics", "zeppelinThreadCount", "Application", "${local.kinesis_studio_name}" ]
                ],
                "stat": "Average",
                "title": "Apache Zeppelin thread count (Count)"
            }
        },
        {
            "height": 5,
            "width": 6,
            "y": 36,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    }
                },
                "metrics": [
                    [ "AWS/KinesisAnalytics", "zeppelinWaitingJobs", "Application", "${local.kinesis_studio_name}" ]
                ],
                "stat": "Average",
                "title": "Apache Zeppelin waiting jobs (Count)"
            }
        },
        {
            "height": 1,
            "width": 6,
            "y": 0,
            "x": 18,
            "type": "text",
            "properties": {
                "markdown": "### **Kinesis Data Studio: ${local.kinesis_studio_name}**"
            }
        }
    ]
}
EOF
}
