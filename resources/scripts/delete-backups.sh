#!/bin/bash

VAULT=$1

aws backup list-recovery-points-by-backup-vault --backup-vault-name ${VAULT} --query 'RecoveryPoints[].RecoveryPointArn' | jq -r -c '.[]' | xargs -n1 -I {} aws backup delete-recovery-point --backup-vault-name ${VAULT} --recovery-point-arn {}