variable "vpc_settings" {
  description = "Map of AWS VPC settings"
  default = {
    private_subnets = ["172.20.16.0/22", "172.20.20.0/22"]
    public_subnets      = ["172.20.0.0/22", "172.20.4.0/22"]
    dns_hostnames       = true
    data_subnets        = ["172.20.8.0/22", "172.20.12.0/22"]
    dns_support         = true
    tenancy             = "default"
    cidr                = "172.20.0.0/16"
  }
  type = object({
    private_subnets = list(string)
    public_subnets      = list(string)
    data_subnets        = list(string)
    dns_hostnames       = bool,
    dns_support         = bool,
    tenancy             = string,
    cidr                = string
  })
}

variable "description" {
  description = "A description for the VPC"
  default     = "VPC created by terraform"
  type        = string
}

variable "identifier" {
  description = "Name of the VPC"
  type        = string
}

variable "region" {
  description = "Region where the VPC will be deployed"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map
}

variable "flow_log_settings" {
  description = "Map of VPC Flow Logs settings"
  default = {
    enable_flow_log      = false
    traffic_type         = "ALL"
  }
  type = object({
    enable_flow_log      = bool,
    traffic_type         = string,
  })
}

variable "log_destination" {
  description = "Cloud watch log group where flow logs will be sent"
  default     = ""
  type        = string
}

variable "iam_role_arn" {
  description = "Iam role to manage flow logs"
  default     = ""
  type        = string
}