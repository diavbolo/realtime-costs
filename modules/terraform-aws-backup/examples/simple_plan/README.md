# Simple plan using lists

This example shows you how to create a simple plan using lists instead of variables:

```
module "aws_backup_example" {

  source = "lgallard/backup/aws"

  # Vault
  vault_name = "vault-1"

  # Plan
  plan_name = "simple-plan-list"

  # One rule using a list of maps
  rules = [
    {
      name                     = "rule-1"
      schedule                 = "cron(0 12 * * ? *)"
      start_window             = 120
      completion_window        = 360
      enable_continuous_backup = true
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 90
      },
      recovery_point_tags = {
        Environment = "production"
      }
    },
  ]

  # One selection using a list of maps
  selections = [
    {
      name      = "selection-1"
      resources = ["arn:aws:dynamodb:us-east-1:123456789101:table/mydynamodb-table1"]
      selection_tags = {
        type  = "STRINGEQUALS"
        key   = "Environment"
        value = "production"
      }
    },
    {
      name      = "selection-2"
      resources = ["arn:aws:dynamodb:us-east-1:123456789101:table/mydynamodb-table2"]
    },
  ]

  tags = {
    Owner       = "devops"
    Environment = "production"
    Terraform   = true
  }

}
```
