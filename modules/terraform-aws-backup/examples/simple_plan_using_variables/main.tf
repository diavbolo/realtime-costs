module "aws_backup_example" {

  source = "lgallard/backup/aws"

  # Vault
  vault_name = "vault-0"

  # Plan
  plan_name = "simple-plan"

  # One rule
  rule_name                         = "rule-1"
  rule_schedule                     = "cron(0 12 * * ? *)"
  rule_start_window                 = 120
  rule_completion_window            = 360
  rule_lifecycle_cold_storage_after = 30
  rule_lifecycle_delete_after       = 120
  rule_enable_continuous_backup     = true

  # One selection
  selection_name      = "selection-1"
  selection_resources = ["arn:aws:dynamodb:us-east-1:123456789101:table/mydynamodb-table"]

  # Tags
  tags = {
    Owner       = "devops"
    Environment = "production"
    Terraform   = true
  }
}
