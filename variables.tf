variable "availability_zone" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  default = {}
  type    = map(string)
}
