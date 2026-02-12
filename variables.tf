variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "environment" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "instance_name" {
  type = string
}

