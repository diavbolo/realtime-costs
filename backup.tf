
module "backup" {
  source = "./modules/terraform-aws-backup"

  # Plan
  plan_name = local.backup_name

  # Vault
  vault_name = local.backup_name

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
        delete_after       = 30
      },
      copy_actions = [
        {
          lifecycle = {
            cold_storage_after = 0
            delete_after       = 90
          },
          destination_vault_arn = "arn:aws:backup:${var.region}:${data.aws_caller_identity.current.account_id}:backup-vault:${local.backup_name}"
        },
      ]
    }
  ]

  selections = [
    {
      name      = "dynamodb_status"
      resources = [aws_dynamodb_table.status.arn]
    },
    {
      name      = "dynamodb_logging"
      resources = [aws_dynamodb_table.logging.arn]
    },
    {
      name      = "dynamodb_config"
      resources = [aws_dynamodb_table.config.arn]
    },
    {
      name      = "mysql"
      resources = [aws_db_instance.mysql.arn]
    }
  ]

}

resource "aws_backup_vault_notifications" "backup_events" {
  backup_vault_name   = local.backup_name
  sns_topic_arn       = aws_sns_topic.sns_alert.arn
  backup_vault_events = ["BACKUP_JOB_FAILED", "RESTORE_JOB_COMPLETED"]
}

resource "null_resource" "backup_vault_destroy" {
  triggers = {
    backup_name = local.backup_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/resources/scripts/delete-backups.sh delete ${self.triggers.backup_name}"
  }

}
