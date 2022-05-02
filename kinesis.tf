
resource "aws_iam_role" "kinesis" {
  name = local.kinesis_ec2_name

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "firehose.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF
}

data "aws_iam_policy_document" "kinesis" {
  statement {
    effect = "Allow"
    actions = [
      "kinesis:Describe*",
      "kinesis:Get*",
      "kinesis:List*",
      "kinesis:Put*",
      "kinesis:SubscribeToShard",
    ]
    resources = [
      "${aws_kinesis_stream.kinesis.arn}",
      "${aws_kinesis_stream.kinesis.arn}/*",
      "${aws_kinesis_stream.kinesis_enriched.arn}",
      "${aws_kinesis_stream.kinesis_enriched.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "glue:GetDatabase*",
      "glue:GetTable*",
      "glue:GetPartitions",
      "glue:GetUserDefinedFunction",
      "glue:CreateTable",
      "glue:DeleteTable*",
      "glue:UpdateTable*"
    ]
    resources = [
      "${aws_glue_catalog_database.aws_glue_catalog_database.arn}",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:database/hive",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:table/${local.glue_db_name}/*",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:userDefinedFunction/${local.glue_db_name}",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:userDefinedFunction/${local.glue_db_name}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:Put*"
    ]
    resources = [
      "${aws_s3_bucket.s3_bucket_costs.arn}",
      "${aws_s3_bucket.s3_bucket_costs.arn}/*"
    ]
  }

}

resource "aws_iam_policy" "kinesis" {
  name = local.kinesis_ec2_name

  path   = "/"
  policy = data.aws_iam_policy_document.kinesis.json
}

resource "aws_iam_role_policy_attachment" "attach_kinesis_policy_to_kinesis_role" {
  role       = aws_iam_role.kinesis.name
  policy_arn = aws_iam_policy.kinesis.arn
}

resource "aws_kinesis_stream" "kinesis" {
  name                      = local.kinesis_ec2_name
  retention_period          = 24
  encryption_type           = "NONE"
  shard_level_metrics       = ["IncomingBytes", "OutgoingBytes"]
  enforce_consumer_deletion = true


  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}

resource "aws_kinesis_stream" "kinesis_enriched" {
  name                      = local.kinesis_ec2_enriched_name
  retention_period          = 24
  encryption_type           = "NONE"
  shard_level_metrics       = ["IncomingBytes", "OutgoingBytes"]
  enforce_consumer_deletion = true

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}

# The schema is required in advance for Firehose's Dynamic Partitioning
resource "aws_glue_catalog_table" "ec2_streams_schema" {
  name          = var.ec2_streams_schema_name
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.s3_bucket_costs.bucket}/${var.bucket_folder_ec2_streams}/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    columns {
      name = "amilaunchindex"
      type = "int"
    }

    columns {
      name = "imageid"
      type = "string"
    }

    columns {
      name = "instanceid"
      type = "string"
    }

    columns {
      name = "instancetype"
      type = "string"
    }

    columns {
      name = "launchtime"
      type = "string"
    }

    columns {
      name = "monitoring"
      type = "struct<State:string>"
    }

    columns {
      name = "placement"
      type = "struct<AvailabilityZone:string,GroupName:string,Tenancy:string>"
    }

    columns {
      name = "privatednsname"
      type = "string"
    }

    columns {
      name = "privateipaddress"
      type = "string"
    }

    columns {
      name = "productcodes"
      type = "array<string>"
    }

    columns {
      name = "publicdnsname"
      type = "string"
    }

    columns {
      name = "publicipaddress"
      type = "string"
    }

    columns {
      name = "state"
      type = "struct<Code:int,Name:string>"
    }

    columns {
      name = "statetransitionreason"
      type = "string"
    }

    columns {
      name = "subnetid"
      type = "string"
    }

    columns {
      name = "vpcid"
      type = "string"
    }

    columns {
      name = "architecture"
      type = "string"
    }

    columns {
      name = "blockdevicemappings"
      type = "array<struct<DeviceName:string,Ebs:struct<AttachTime:string,DeleteOnTermination:boolean,Status:string,VolumeId:string>>>"
    }

    columns {
      name = "clienttoken"
      type = "string"
    }

    columns {
      name = "ebsoptimized"
      type = "boolean"
    }

    columns {
      name = "enasupport"
      type = "boolean"
    }

    columns {
      name = "hypervisor"
      type = "string"
    }

    columns {
      name = "networkinterfaces"
      type = "array<struct<Association:struct<IpOwnerId:string,PublicDnsName:string,PublicIp:string>,Attachment:struct<AttachTime:string,AttachmentId:string,DeleteOnTermination:boolean,DeviceIndex:int,Status:string,NetworkCardIndex:int>,Description:string,Groups:array<struct<GroupName:string,GroupId:string>>,Ipv6Addresses:array<string>,MacAddress:string,NetworkInterfaceId:string,OwnerId:string,PrivateDnsName:string,PrivateIpAddress:string,PrivateIpAddresses:array<struct<Association:struct<IpOwnerId:string,PublicDnsName:string,PublicIp:string>,Primary:boolean,PrivateDnsName:string,PrivateIpAddress:string>>,SourceDestCheck:boolean,Status:string,SubnetId:string,VpcId:string,InterfaceType:string>>"
    }

    columns {
      name = "rootdevicename"
      type = "string"
    }

    columns {
      name = "rootdevicetype"
      type = "string"
    }

    columns {
      name = "securitygroups"
      type = "array<struct<GroupName:string,GroupId:string>>"
    }

    columns {
      name = "sourcedestcheck"
      type = "boolean"
    }

    columns {
      name = "virtualizationtype"
      type = "string"
    }

    columns {
      name = "cpuoptions"
      type = "struct<CoreCount:int,ThreadsPerCore:int>"
    }

    columns {
      name = "capacityreservationspecification"
      type = "struct<CapacityReservationPreference:string>"
    }

    columns {
      name = "hibernationoptions"
      type = "struct<Configured:boolean>"
    }

    columns {
      name = "metadataoptions"
      type = "struct<State:string,HttpTokens:string,HttpPutResponseHopLimit:int,HttpEndpoint:string,HttpProtocolIpv6:string>"
    }

    columns {
      name = "enclaveoptions"
      type = "struct<Enabled:boolean>"
    }

    columns {
      name = "platformdetails"
      type = "string"
    }

    columns {
      name = "usageoperation"
      type = "string"
    }

    columns {
      name = "usageoperationupdatetime"
      type = "string"
    }

    columns {
      name = "instancelifecycle"
      type = "string"
    }

    columns {
      name = "spotinstancerequestid"
      type = "string"
    }

    columns {
      name = "tags"
      type = "array<struct<Key:string,Value:string>>"
    }

    columns {
      name = "keyname"
      type = "string"
    }

    columns {
      name = "platform"
      type = "string"
    }

    columns {
      name = "iaminstanceprofile"
      type = "struct<Arn:string,Id:string>"
    }

    columns {
      name = "statereason"
      type = "struct<Code:string,Message:string>"
    }

    columns {
      name = "accountid"
      type = "string"
    }

  }
}

# Dynamic partitioning cannot be set yet from TF so it needs to be deployed via AWS cli
resource "null_resource" "kinesis_firehose_create" {
  depends_on = [aws_iam_role_policy_attachment.attach_kinesis_policy_to_kinesis_role, aws_kinesis_stream.kinesis, aws_glue_catalog_table.ec2_streams_schema]

  triggers = {
    md5              = md5(local_file.kinesis_firehose.content)
    kinesis_ec2_name = local.kinesis_ec2_name
  }

  provisioner "local-exec" {
    command = "${path.module}/resources/scripts/kinesis-firehose.sh create ${self.triggers.kinesis_ec2_name} ${local_file.kinesis_firehose.filename}"
  }

}

resource "null_resource" "kinesis_firehose_destroy" {
  triggers = {
    kinesis_ec2_name = local.kinesis_ec2_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/resources/scripts/kinesis-firehose.sh delete ${self.triggers.kinesis_ec2_name}"
  }

}

resource "local_file" "kinesis_firehose" {
  filename = "${path.module}/temp/kinesis-firehose.json"
  content = jsonencode(
    {
      "DeliveryStreamName" : local.kinesis_ec2_name,
      "DeliveryStreamType" : "KinesisStreamAsSource",
      "KinesisStreamSourceConfiguration" : {
        "KinesisStreamARN" : aws_kinesis_stream.kinesis.arn,
        "RoleARN" : aws_iam_role.kinesis.arn
      },
      "ExtendedS3DestinationConfiguration" : {
        "RoleARN" : aws_iam_role.kinesis.arn,
        "BucketARN" : aws_s3_bucket.s3_bucket_costs.arn,
        "BufferingHints" : {
          "SizeInMBs" : 64,
          "IntervalInSeconds" : 120
        },
        "CloudWatchLoggingOptions" : {
          "Enabled" : true,
          "LogGroupName" : "${local.kinesis_ec2_name}-firehose",
          "LogStreamName" : "${local.kinesis_ec2_name}-firehose"
        },
        "DataFormatConversionConfiguration" : {
          "Enabled" : true,
          "InputFormatConfiguration" : {
            "Deserializer" : {
              "OpenXJsonSerDe" : {
                "CaseInsensitive" : true,
                "ColumnToJsonKeyMappings" : {
                },
                "ConvertDotsInJsonKeysToUnderscores" : true
              }
            }
          },
          "OutputFormatConfiguration" : {
            "Serializer" : {
              "ParquetSerDe" : {
                "Compression" : "GZIP",
                "EnableDictionaryCompression" : true,
                "MaxPaddingBytes" : 0,
                "WriterVersion" : "V2"
              }
            }
          },
          "SchemaConfiguration" : {
            "RoleARN" : aws_iam_role.kinesis.arn,
            "DatabaseName" : aws_glue_catalog_database.aws_glue_catalog_database.name,
            "TableName" : aws_glue_catalog_table.ec2_streams_schema.name,
          }
        },
        "DynamicPartitioningConfiguration" : {
          "Enabled" : true,
          "RetryOptions" : {
            "DurationInSeconds" : 0
          }
        },
        "ErrorOutputPrefix" : var.bucket_folder_ec2_streams_errors,
        "Prefix" : "${var.bucket_folder_ec2_streams}/!{partitionKeyFromQuery:AccountId}/!{partitionKeyFromQuery:year}/!{partitionKeyFromQuery:month}/!{partitionKeyFromQuery:day}/!{partitionKeyFromQuery:hour}/",
        "ProcessingConfiguration" : {
          "Enabled" : true,
          "Processors" : [
            {
              "Type" : "MetadataExtraction",
              "Parameters" : [
                {
                  "ParameterName" : "JsonParsingEngine",
                  "ParameterValue" : "JQ-1.6"
                },
                {
                  "ParameterName" : "MetadataExtractionQuery",
                  "ParameterValue" : "{AccountId:.AccountId,year:now|strftime(\"%Y\"),month:now|strftime(\"%m\"),day:now|strftime(\"%d\"),hour:now|strftime(\"%H\")}"
                }
              ]
            }
          ]
        },
        "S3BackupMode" : "Disabled"
      }
    }
  )
}

# Not available yet in Terraform so it needs to be deployed via AWS cli
resource "null_resource" "kinesis_studio_create" {
  depends_on = [aws_iam_role_policy_attachment.attach_kinesis_studio_policy_to_kinesis_studio_role, aws_kinesis_stream.kinesis, aws_glue_catalog_table.ec2_streams_schema]

  triggers = {
    md5                 = md5(local_file.kinesis_studio.content)
    kinesis_studio_name = local.kinesis_studio_name
  }

  provisioner "local-exec" {
    command = "${path.module}/resources/scripts/kinesis-studio.sh create ${self.triggers.kinesis_studio_name} ${local_file.kinesis_studio.filename}"
  }

}

resource "null_resource" "kinesis_studio_destroy" {
  triggers = {
    kinesis_studio_name = local.kinesis_studio_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/resources/scripts/kinesis-studio.sh delete ${self.triggers.kinesis_studio_name}"
  }

}

resource "local_file" "kinesis_studio" {
  filename = "${path.module}/temp/kinesis-studio.json"
  content = jsonencode(
    {
      "ApplicationName" : "${local.kinesis_studio_name}",
      "RuntimeEnvironment" : "ZEPPELIN-FLINK-2_0",
      "ApplicationMode" : "INTERACTIVE",
      "ServiceExecutionRole" : aws_iam_role.kinesis_studio.arn,
      "CloudWatchLoggingOptions" : [
        {
          "LogStreamARN" : aws_cloudwatch_log_stream.kinesis_studio.arn
        }
      ],
      "ApplicationConfiguration" : {
        "VpcConfigurations" : [
          {
            "SubnetIds" : [
              "${aws_subnet.private_network.id}",
              "${aws_subnet.private_network1.id}"
            ],
            "SecurityGroupIds" : [
              "${aws_security_group.kinesis_studio.id}"
            ]
          }
        ],
        "FlinkApplicationConfiguration" : {
          "ParallelismConfiguration" : {
            "ConfigurationType" : "CUSTOM",
            "Parallelism" : 8,
            "ParallelismPerKPU" : 4
          }
        },
        "ApplicationSnapshotConfiguration" : {
          "SnapshotsEnabled" : false
        },
        "ZeppelinApplicationConfiguration" : {
          "CatalogConfiguration" : {
            "GlueDataCatalogConfiguration" : {
              "DatabaseARN" : aws_glue_catalog_database.aws_glue_catalog_database.arn
            }
          },
          "DeployAsApplicationConfiguration" : {
            "S3ContentLocation" : {
              "BucketARN" : aws_s3_bucket.s3_bucket_costs.arn,
              "BasePath" : "code/"
            }
          },
          "CustomArtifactsConfiguration" : [
            {
              "ArtifactType" : "DEPENDENCY_JAR",
              "MavenReference" : {
                "GroupId" : "org.apache.flink",
                "ArtifactId" : "flink-sql-connector-kinesis_2.12",
                "Version" : "1.13.2"
              }
            },
            {
              "ArtifactType" : "DEPENDENCY_JAR",
              "MavenReference" : {
                "GroupId" : "software.amazon.msk",
                "ArtifactId" : "aws-msk-iam-auth",
                "Version" : "1.1.0"
              }
            },
            {
              "ArtifactType" : "DEPENDENCY_JAR",
              "MavenReference" : {
                "GroupId" : "org.apache.flink",
                "ArtifactId" : "flink-connector-kafka_2.12",
                "Version" : "1.13.2"
              }
            },
            {
              "ArtifactType" : "DEPENDENCY_JAR",
              "S3ContentLocation" : {
                "BucketARN" : aws_s3_bucket.s3_bucket_costs.arn,
                "FileKey" : aws_s3_bucket_object.flink_sql_connector_elasticsearch.key
              }
            },
            {
              "ArtifactType" : "DEPENDENCY_JAR",
              "S3ContentLocation" : {
                "BucketARN" : aws_s3_bucket.s3_bucket_costs.arn,
                "FileKey" : aws_s3_bucket_object.mysql_connector.key
              }
            },
            {
              "ArtifactType" : "DEPENDENCY_JAR",
              "S3ContentLocation" : {
                "BucketARN" : aws_s3_bucket.s3_bucket_costs.arn,
                "FileKey" : aws_s3_bucket_object.flink_connector_jdbc.key
              }
            },
            {
              "ArtifactType" : "UDF",
              "S3ContentLocation" : {
                "BucketARN" : aws_s3_bucket.s3_bucket_costs.arn,
                "FileKey" : aws_s3_bucket_object.flink_udf.key
              }
            }
          ]
        }
      }
    }
  )
}
resource "aws_cloudwatch_log_stream" "kinesis_studio" {
  name           = local.kinesis_studio_name
  log_group_name = aws_cloudwatch_log_group.kinesis_studio.name
}

resource "aws_cloudwatch_log_group" "kinesis_studio" {
  name = "/aws/kinesis-analytics/${local.kinesis_studio_name}"
}

resource "aws_s3_bucket_object" "flink_connector_jdbc" {
  bucket = aws_s3_bucket.s3_bucket_costs.bucket
  key    = "libs/flink-connector-jdbc_2.11-1.13.5.jar"
  source = "${path.module}/resources/flink/libs/flink-connector-jdbc_2.11-1.13.5.jar"
}

resource "aws_s3_bucket_object" "mysql_connector" {
  bucket = aws_s3_bucket.s3_bucket_costs.bucket
  key    = "libs/mysql-connector-java-8.0.23.jar"
  source = "${path.module}/resources/flink/libs/mysql-connector-java-8.0.23.jar"
}

resource "aws_s3_bucket_object" "flink_sql_connector_elasticsearch" {
  bucket = aws_s3_bucket.s3_bucket_costs.bucket
  key    = "libs/flink-sql-connector-elasticsearch7_2.11-1.13.5.jar"
  source = "${path.module}/resources/flink/libs/flink-sql-connector-elasticsearch7_2.11-1.13.5.jar"
}

resource "aws_s3_bucket_object" "flink_udf" {
  bucket = aws_s3_bucket.s3_bucket_costs.bucket
  key    = "libs/flink-udf-1.0-SNAPSHOT-jar-with-dependencies.jar"
  source = "${path.module}/resources/flink/libs/flink-udf-1.0-SNAPSHOT-jar-with-dependencies.jar"
}

resource "aws_iam_role" "kinesis_studio" {
  name = local.kinesis_studio_name
  path = "/service-role/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "kinesisanalytics.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
}
EOF
}

data "aws_iam_policy_document" "kinesis_studio" {
  statement {
    effect = "Allow"
    actions = [
      "kinesis:Describe*",
      "kinesis:Get*",
      "kinesis:List*",
      "kinesis:Put*",
      "kinesis:SubscribeToShard",
      "kinesis:RegisterStreamConsumer"
    ]
    resources = [
      "${aws_kinesis_stream.kinesis.arn}",
      "${aws_kinesis_stream.kinesis.arn}/*",
      "${aws_kinesis_stream.kinesis_enriched.arn}",
      "${aws_kinesis_stream.kinesis_enriched.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "glue:GetDatabase*",
      "glue:GetTable*",
      "glue:GetPartitions",
      "glue:GetUserDefinedFunction",
      "glue:CreateTable",
      "glue:DeleteTable*",
      "glue:UpdateTable*"
    ]
    resources = [
      "${aws_glue_catalog_database.aws_glue_catalog_database.arn}",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:database/hive",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:table/${local.glue_db_name}/*",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:userDefinedFunction/${local.glue_db_name}",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:userDefinedFunction/${local.glue_db_name}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["kinesisanalytics:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:ListSecrets"
    ]
    resources = [
      "${aws_secretsmanager_secret.db_creds.arn}",
      "${aws_secretsmanager_secret.es_creds.arn}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:Create*",
      "logs:Describe*",
      "logs:Get*",
      "logs:Put*"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Put*"
    ]
    resources = [
      "${aws_s3_bucket.s3_bucket_costs.arn}",
      "${aws_s3_bucket.s3_bucket_costs.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:Describe*",
      "dynamodb:List*",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:PartiQLSelect"
    ]
    resources = [
      "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeDhcpOptions",
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }

}

resource "aws_iam_policy" "kinesis_studio" {
  name = local.kinesis_studio_name

  path   = "/"
  policy = data.aws_iam_policy_document.kinesis_studio.json
}

resource "aws_iam_role_policy_attachment" "attach_kinesis_studio_policy_to_kinesis_studio_role" {
  role       = aws_iam_role.kinesis_studio.name
  policy_arn = aws_iam_policy.kinesis_studio.arn
}

resource "aws_security_group" "kinesis_studio" {
  name        = local.kinesis_studio_name
  description = local.kinesis_studio_name
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
