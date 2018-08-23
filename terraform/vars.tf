variable "AWS_REGION" {
  default = "us-east-1"
}

variable "NAME" {
  default = "mikes"
}

variable "PORT" {
  default = 3000
}

variable "CPU" {
  default     = 1024
}

variable "MEMORY" {
  default     = 4096
}

variable "CIDR_PRIVATE" {
  default = "10.0.1.0/24,10.0.2.0/24"
}

variable "CIDR_PUBLIC" {
  default = "10.0.101.0/24,10.0.102.0/24"
}

