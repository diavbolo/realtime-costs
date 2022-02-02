
resource "aws_dynamodb_table" "logging" {
  name         = "logging"
  hash_key     = "timestamp"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "timestamp"
    type = "S"
  }

}

resource "aws_dynamodb_table" "status" {
  name         = "status"
  hash_key     = "account_id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "account_id"
    type = "S"
  }

}

resource "aws_dynamodb_table" "config" {
  name         = "config"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  provisioner "local-exec" {
    command = "aws dynamodb batch-write-item --request-items file://${local_file.dynamodb_variables.filename}"
  }
}

resource "local_file" "dynamodb_variables" {
  filename = "${path.module}/temp/dynamodb-variables.json"
  content = jsonencode(
    {
      "config" : [
        {
          "PutRequest" : {
            "Item" : {
              "id" : {
                "S" : "region"
              },
              "value" : {
                "S" : "${var.region}"
              }
            }
          }
        },
        {
          "PutRequest" : {
            "Item" : {
              "id" : {
                "S" : "mysql_host"
              },
              "value" : {
                "S" : "${aws_route53_record.mysql_subdomain.name}"
              }
            }
          }
        },
        {
          "PutRequest" : {
            "Item" : {
              "id" : {
                "S" : "mysql_db"
              },
              "value" : {
                "S" : "${var.mysql_db_name}"
              }
            }
          }
        },
        {
          "PutRequest" : {
            "Item" : {
              "id" : {
                "S" : "mysql_table"
              },
              "value" : {
                "S" : "${var.mysql_table_name}"
              }
            }
          }
        },
        {
          "PutRequest" : {
            "Item" : {
              "id" : {
                "S" : "mysql_secret"
              },
              "value" : {
                "S" : "${aws_secretsmanager_secret.db_creds.name}"
              }
            }
          }
        },
        {
          "PutRequest" : {
            "Item" : {
              "id" : {
                "S" : "es_host"
              },
              "value" : {
                "S" : "${aws_route53_record.es_subdomain.name}"
              }
            }
          }
        },
        {
          "PutRequest" : {
            "Item" : {
              "id" : {
                "S" : "es_index"
              },
              "value" : {
                "S" : "${var.es_ec2_index_name}"
              }
            }
          }
        },
        {
          "PutRequest" : {
            "Item" : {
              "id" : {
                "S" : "es_secret"
              },
              "value" : {
                "S" : "${aws_secretsmanager_secret.es_creds.name}"
              }
            }
          }
        },
        {
          "PutRequest" : {
            "Item" : {
              "id" : {
                "S" : "s3_bucket"
              },
              "value" : {
                "S" : "${var.bucket_data_name}"
              }
            }
          }
        },
        {
          "PutRequest" : {
            "Item" : {
              "id" : {
                "S" : "s3_folder"
              },
              "value" : {
                "S" : "${var.bucket_folder_ec2_costs}"
              }
            }
          }
        },
        {
          "PutRequest" : {
            "Item" : {
              "id" : {
                "S" : "kinesis_ec2"
              },
              "value" : {
                "S" : "${local.kinesis_ec2_name}"
              }
            }
          }
        },
        {
          "PutRequest" : {
            "Item" : {
              "id" : {
                "S" : "kinesis_ec2_enriched"
              },
              "value" : {
                "S" : "${local.kinesis_ec2_enriched_name}"
              }
            }
          }
        }
      ]
    }
  )
}
