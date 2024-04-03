variable "availability_zone" {
  type = string
}

variable "deploy" {
  type    = bool
}

variable "environment" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  default = {}
  type    = map(string)
}
