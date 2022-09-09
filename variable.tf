
variable "vpc_cidr" {
  description = "cidr for vpc"
  type        = string
}

variable "public_cidr" {
  description = "cidr for public subnet"
  type        = list(any)
}
# 
variable "private_cidr" {
  description = "cidr for public subnet"
  type        = list(any)
}
# 
variable "database_cidr" {
  description = "cidr for public subnet"
  type        = list(any)
}

variable "component_name" {
  default = "kojitechs"
}

variable "tag_name" {
  type        = list(any)
  description = "(optional) describe your variable"
  default     = ["RegistationAPP_A", "RegistrationAPP_B"]
}