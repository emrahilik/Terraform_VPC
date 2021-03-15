variable "identifier" {
  description = "The name of the security group"
  type        = string
}

variable "retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  default     = 30
  type        = number
}

variable "kms_key_arn" {
  description = "Specifies the kms key arn to encrypt the logs"
  default     = ""
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map
}
