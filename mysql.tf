
resource "aws_db_instance" "mysql" {
  depends_on = [null_resource.backup_vault_destroy]

  identifier               = local.mysql_name
  allocated_storage        = var.mysql_storage
  engine                   = "mysql"
  engine_version           = "5.7"
  instance_class           = var.mysql_instance
  name                     = var.mysql_db_name
  username                 = var.mysql_user
  password                 = local.db_creds.password
  parameter_group_name     = "default.mysql5.7"
  skip_final_snapshot      = true
  vpc_security_group_ids   = ["${aws_security_group.mysql.id}"]
  publicly_accessible      = true
  db_subnet_group_name     = aws_db_subnet_group.mysql.name
  delete_automated_backups = true
}

resource "null_resource" "mysql_create_table" {

  provisioner "local-exec" {
    command = "mysql --host=${aws_route53_record.mysql_subdomain.name} --user=${var.mysql_user} --password=${local.db_creds.password} --database=${var.mysql_db_name} < ${local_file.create_table.filename}"
  }

}

resource "aws_db_subnet_group" "mysql" {
  name       = "public"
  subnet_ids = [aws_subnet.public_network.id, aws_subnet.public_network1.id]
}

resource "aws_security_group" "mysql" {
  name        = local.mysql_name
  description = local.mysql_name
  vpc_id      = aws_vpc.main.id

  # Allow access from the current client public IP so the table schema can be created
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    description = "My IP"
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["52.210.255.224/27"]
    description = "QuickSight for ${var.region}"
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_subnet]
    description = "Internal VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "glue" {
  name        = local.glue_name
  description = local.glue_name
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

resource "local_file" "create_table" {
  filename = "${path.module}/temp/create-table.sql"
  content  = <<-EOF
CREATE TABLE IF NOT EXISTS ${var.mysql_table_name} (
  ts TIMESTAMP,
  region VARCHAR(50),
  `type` VARCHAR(50),
  tenancy VARCHAR(50),
  os VARCHAR(50),
  sqlserver VARCHAR(50),
  licensemodel VARCHAR(50),
  termtype VARCHAR(50),
  capacitystatus VARCHAR(50),
  unit VARCHAR(50),
  leasecontractlength VARCHAR(50),
  purchaseoption VARCHAR(50),
  cost DOUBLE,
  PRIMARY KEY (
    region,
    `type`,
    tenancy,
    os,
    sqlserver
  )
);
EOF
}

resource "random_password" "db_creds" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "db_creds" {
  name                    = "${local.secrets_name}/mysql"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_creds" {
  secret_id     = aws_secretsmanager_secret.db_creds.id
  secret_string = <<EOF
   {
    "username": "${var.mysql_user}",
    "password": "${random_password.db_creds.result}"
   }
EOF
}

data "aws_secretsmanager_secret" "db_creds" {
  arn = aws_secretsmanager_secret.db_creds.arn
}

data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = data.aws_secretsmanager_secret.db_creds.arn
}

resource "aws_glue_connection" "mysql" {
  connection_type = "JDBC"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:mysql://${aws_route53_record.mysql_subdomain.name}:3306/${var.mysql_db_name}"
    PASSWORD            = "${local.db_creds.password}"
    USERNAME            = "${var.mysql_user}"
  }

  name = local.mysql_name

  physical_connection_requirements {
    availability_zone      = aws_subnet.private_network.availability_zone
    security_group_id_list = [aws_security_group.glue.id]
    subnet_id              = aws_subnet.private_network.id
  }
}
