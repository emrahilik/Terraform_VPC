variable "identifier" {
  description = "Name for the resources"
  type        = string
}

variable "description" {
  description = "Description for the IAM role"
  default     = "Created by terraform"
  type        = string
}

variable "policy" {
  description = "policy for the IAM role"
  default     = "Created by terraform"
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map
}
