# Complete Plan

This example shows you how to create a complete plan, using several resources and options:

```
module "aws_backup_example" {

  source = "lgallard/backup/aws"

  # Vault
  vault_name = "vault-3"

  # Plan
  plan_name = "complete-plan"

  # Multiple rules using a list of maps
  rules = [
    {
      name                     = "rule-1"
      schedule                 = "cron(0 12 * * ? *)"
      target_vault_name        = null
      start_window             = 120
      completion_window        = 360
      enable_continuous_backup = true
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 90
      },
      copy_actions = [{
        lifecycle = {
          cold_storage_after = 0
          delete_after       = 30
        },
        destination_vault_arn = "arn:aws:backup:us-west-2:123456789101:backup-vault:Default"
      }]
      recovery_point_tags = {
        Environment = "production"
      }
    },
    {
      name                = "rule-2"
      target_vault_name   = "Default"
      schedule            = null
      start_window        = 120
      completion_window   = 360
      lifecycle           = {}
      copy_actions        = []
      recovery_point_tags = {}
    },
  ]

  # Multiple selections
  #  - Selection-1: By resources and tag
  #  - Selection-2: Only by resources
  selections = [
    {
      name      = "selection-1"
      resources = ["arn:aws:dynamodb:us-east-1:123456789101:table/mydynamodb-table1"]
      selection_tags = [
        {
          type  = "STRINGEQUALS"
          key   = "Environment"
          value = "production"
        },
        {
          type  = "STRINGEQUALS"
          key   = "Owner"
          value = "production"
        }
      ]
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
