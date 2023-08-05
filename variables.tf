variable "vpc-cidr" {
  type        = string
  default     = ""
  description = "VPC CIDR block"
}

variable "internet" {
  type = string
  default = ""
  description = "Internet IP"
}
