output "rds_endpoints" {
  value = {
    for service, db in aws_db_instance.postgres :
    service => db.address
  }
}

output "rds_identifiers" {
  value = {
    for service, db in aws_db_instance.postgres :
    service => db.identifier
  }
}