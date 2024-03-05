variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "db_username" {
  description = "The username for the RDS database"
  type        = string
}

variable "db_password" {
  description = "The password for the RDS database"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The name of the RDS database"
  type        = string
}

variable "grafana_username" {
  description = "The username for the Grafana"
  type        = string
}

variable "grafana_password" {
  description = "The password for the Grafana"
  type        = string
  sensitive   = true
}
