![Terraform](https://lgallardo.com/images/terraform.jpg)
# terraform-aws-backup

Terraform module to create [AWS Backup](https://aws.amazon.com/backup/) plans.  AWS Backup is a fully managed backup service that makes it easy to centralize and automate the back up of data across AWS services (EBS volumes, RDS databases, DynamoDB tables, EFS file systems, and Storage Gateway volumes).

## Usage

You can use this module to create a simple plan using the module's `rule_*` variables. You can also  use the `rules` and `selections` list of maps variables to build a more complete plan by defining several rules and selections at once.

Check the [examples](examples/) for the **simple plan**, **complete plan**, **simple plan using variables** and the **selection by tags plan** snippets.

### Example (complete plan)

This example creates a plan with two rules and two selections at once. It also defines a vault key which is used by the first rule because no `target_vault_name` was given (null). Whereas the second rule is using the "Default" vault key.

The first selection has two assignments, the first defined by a resource ARN and the second one defined by a tag condition. The second selection has just one assignment defined by a resource ARN.

```
module "aws_backup_example" {

  source = "lgallard/backup/aws"

  # Vault
  vault_name = "vault-3"

  # Plan
  plan_name = "complete-plan"

  # Notifications
  notifications = {
    sns_topic_arn       = aws_sns_topic.backup_vault_notifications.arn
    backup_vault_events = ["BACKUP_JOB_STARTED", "BACKUP_JOB_COMPLETED", "BACKUP_JOB_FAILED", "RESTORE_JOB_COMPLETED"]
  }

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
          destination_vault_arn = "arn:aws:backup:us-west-2:123456789101:backup-vault:Default"
        },
      ]
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
      copy_action         = {}
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
    Owner       = "backup team"
    Environment = "production"
    Terraform   = true
  }
}

```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.20.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_backup_plan.ab_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_selection.ab_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.ab_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault_notifications.backup_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_notifications) | resource |
| [aws_iam_policy.ab_tag_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ab_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ab_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ab_restores_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ab_tag_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sns_topic_policy.backup_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_iam_policy_document.backup_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Change to false to avoid deploying any AWS Backup resources | `bool` | `true` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | If configured, the module will attach this role to selections, instead of creating IAM resources by itself | `string` | `null` | no |
| <a name="input_notifications"></a> [notifications](#input\_notifications) | Notification block which defines backup vault events and the SNS Topic ARN to send AWS Backup notifications to. Leave it empty to disable notifications | `any` | `{}` | no |
| <a name="input_plan_name"></a> [plan\_name](#input\_plan\_name) | The display name of a backup plan | `string` | n/a | yes |
| <a name="input_rule_completion_window"></a> [rule\_completion\_window](#input\_rule\_completion\_window) | The amount of time AWS Backup attempts a backup before canceling the job and returning an error | `number` | `null` | no |
| <a name="input_rule_copy_action_destination_vault_arn"></a> [rule\_copy\_action\_destination\_vault\_arn](#input\_rule\_copy\_action\_destination\_vault\_arn) | An Amazon Resource Name (ARN) that uniquely identifies the destination backup vault for the copied backup. | `string` | `null` | no |
| <a name="input_rule_copy_action_lifecycle"></a> [rule\_copy\_action\_lifecycle](#input\_rule\_copy\_action\_lifecycle) | The lifecycle defines when a protected resource is copied over to a backup vault and when it expires. | `map(any)` | `{}` | no |
| <a name="input_rule_enable_continuous_backup"></a> [rule\_enable\_continuous\_backup](#input\_rule\_enable\_continuous\_backup) | Enable continuous backups for supported resources. | `bool` | `false` | no |
| <a name="input_rule_lifecycle_cold_storage_after"></a> [rule\_lifecycle\_cold\_storage\_after](#input\_rule\_lifecycle\_cold\_storage\_after) | Specifies the number of days after creation that a recovery point is moved to cold storage | `number` | `null` | no |
| <a name="input_rule_lifecycle_delete_after"></a> [rule\_lifecycle\_delete\_after](#input\_rule\_lifecycle\_delete\_after) | Specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `cold_storage_after` | `number` | `null` | no |
| <a name="input_rule_name"></a> [rule\_name](#input\_rule\_name) | An display name for a backup rule | `string` | `null` | no |
| <a name="input_rule_recovery_point_tags"></a> [rule\_recovery\_point\_tags](#input\_rule\_recovery\_point\_tags) | Metadata that you can assign to help organize the resources that you create | `map(string)` | `{}` | no |
| <a name="input_rule_schedule"></a> [rule\_schedule](#input\_rule\_schedule) | A CRON expression specifying when AWS Backup initiates a backup job | `string` | `null` | no |
| <a name="input_rule_start_window"></a> [rule\_start\_window](#input\_rule\_start\_window) | The amount of time in minutes before beginning a backup | `number` | `null` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | A list of rule maps | `any` | `[]` | no |
| <a name="input_selection_name"></a> [selection\_name](#input\_selection\_name) | The display name of a resource selection document | `string` | `null` | no |
| <a name="input_selection_resources"></a> [selection\_resources](#input\_selection\_resources) | An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan | `list(any)` | `[]` | no |
| <a name="input_selection_tags"></a> [selection\_tags](#input\_selection\_tags) | List of tags for `selection_name` var, when using variable definition. | `list(any)` | `[]` | no |
| <a name="input_selections"></a> [selections](#input\_selections) | A list of selction maps | `any` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_vault_kms_key_arn"></a> [vault\_kms\_key\_arn](#input\_vault\_kms\_key\_arn) | The server-side encryption key that is used to protect your backups | `string` | `null` | no |
| <a name="input_vault_name"></a> [vault\_name](#input\_vault\_name) | Name of the backup vault to create. If not given, AWS use default | `string` | `null` | no |
| <a name="input_windows_vss_backup"></a> [windows\_vss\_backup](#input\_windows\_vss\_backup) | Enable Windows VSS backup option and create a VSS Windows backup | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_plan_arn"></a> [plan\_arn](#output\_plan\_arn) | The ARN of the backup plan |
| <a name="output_plan_id"></a> [plan\_id](#output\_plan\_id) | The id of the backup plan |
| <a name="output_plan_role"></a> [plan\_role](#output\_plan\_role) | The service role of the backup plan |
| <a name="output_plan_version"></a> [plan\_version](#output\_plan\_version) | Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan |
| <a name="output_vault_arn"></a> [vault\_arn](#output\_vault\_arn) | The ARN of the vault |
| <a name="output_vault_id"></a> [vault\_id](#output\_vault\_id) | The name of the vault |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Know Issue:

### error creating Backup Vault

In case you get an error message similar to this one:

```
error creating Backup Vault (): AccessDeniedException: status code: 403, request id: 8e7e577e-5b74-4d4d-95d0-bf63e0b2cc2e,
```

Add the [required IAM permissions mentioned in the CreateBackupVault row](https://docs.aws.amazon.com/aws-backup/latest/devguide/access-control.html#backup-api-permissions-ref) to the role or user creating the Vault (the one running Terraform CLI). In particular make sure `kms` and `backup-storage` permissions are added.
