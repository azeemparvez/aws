variable "vpc-cidr" {
  type        = string
  default     = ""
  description = "VPC CIDR block"
}

variable "lb-cidr" {
  type        = list(string)
  default     = []
  description = "CIDR range for Load Balancer Tier"
}
variable "app-cidr" {
  type        = list(string)
  default     = []
  description = "CIDR range for Load Balancer Tier"
}
