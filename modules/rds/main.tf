resource "aws_db_instance" "postgresdb" {
  allocated_storage     = var.rds_storage_size
  max_allocated_storage = 100
  storage_type          = var.rds_storage_type
  instance_class        = var.rds_instance_class

  engine         = "postgres"
  engine_version = "16.3"

  engine_lifecycle_support = "open-source-rds-extended-support-disabled" # extended-support-feature-disabled

  db_name  = var.rds_db_name
  username = var.rds_db_username
  password_wo = var.rds_db_password

  publicly_accessible = false
  multi_az            = false

  skip_final_snapshot      = true # If true, no snapshot will be created
  delete_automated_backups = true # If true, automated backups will be deleted

  vpc_security_group_ids = [aws_security_group.db_sg.id]
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Allow postgres inbound and all outbound"
  vpc_id      = var.vpc_id

  tags = {
    Name = "db_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_postgres_default_port" {
  security_group_id = aws_security_group.db_sg.id

  #referenced_security_group_id = var.security_group_id
  cidr_ipv4   = local.anywhere
  from_port   = local.db_port
  ip_protocol = local.tcp_protocol
  to_port     = local.db_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_db" {
  security_group_id = aws_security_group.db_sg.id
  cidr_ipv4         = local.anywhere
  ip_protocol       = local.all_protocols_ports # semantically equivalent to all ports
}
