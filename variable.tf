
variable "vpc_cidr" {
  description = "cidr for vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_cidr" {
  description = "cidr for public subnet"
  type        = list(any)
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
}
# 
variable "private_cidr" {
  description = "cidr for public subnet"
  type        = list(any)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}
# 
variable "database_cidr" {
  description = "cidr for public subnet"
  type        = list(any)
  default     = ["10.0.51.0/24", "10.0.55.0/24"]
}
# 


variable "component_name" {
  default = "kojitechs-register"
}
