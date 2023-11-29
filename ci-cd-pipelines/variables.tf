variable "project" {
  type        = string
  description = "(Required) Application project name."
}

variable "owner" {
  type        = string
  description = "(Optional) Project Owner. Defaults to Terraform"
  default     = "Terraform"
}

variable "environment" {
  type        = string
  description = "Application environment for deployment."
}

variable "prefix" {
  type        = string
  description = "(Required) This prefix will be included in the name of most resources."
}

variable "region" {
  type        = string
  description = "(Optional) The region where the resources are created. Defaults to eu-central-1."
  default     = "eu-central-1"
}

variable "vpc_id" {
  type = string
  description = "The Vpc where the EKS will be launched"
  default = "vpc-0ed30803f6da52789"
}

variable "private_subnet_ids" {
  type = list(string)
  description = "Private Subnet Ids where the application run"

  default = ["tbd", "tbd"]  
}

variable "public_subnet_ids" {
  type = list(string)
  description = "Public Subnet Ids for the control plane"

  default = ["subnet-0ff95db24b55484c9", "subnet-01c8a2a25a82943f5", "subnet-0bca257e90b15e222"]  
}