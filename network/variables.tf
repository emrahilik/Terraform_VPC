variable "vpc_settings" {
  description = "Map of AWS VPC settings"
  default = {
    private_subnets = ["10.10.16.0/22","10.10.20.0/22"]
    public_subnets      = ["10.10.0.0/22","10.10.4.0/22"]
    dns_hostnames       = true
    data_subnets        = []
    dns_support         = true
    tenancy             = "default"
    cidr                = "10.10.0.0/16"
  }
  type        = object({
    private_subnets = list(string)
    public_subnets      = list(string)
    data_subnets        = list(string)
    dns_hostnames       = bool,
    dns_support         = bool,
    tenancy             = string,
    cidr                = string
    })
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

variable "kms_key_arn" {
  description = "Specifies the kms key arn to encrypt the logs"
  default     = ""
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

variable "profile" {
  description = "The aws profile to use"
  type        = string
}

variable "iam_policies" {
  description = "List of poilices to attach role"
  default     = {}
  type        = map(any)
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map
}
