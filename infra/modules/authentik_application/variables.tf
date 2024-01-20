variable "name" {
  type = string
}

variable "slug" {
  type = string
}

variable "protocol_provider" {
  type = number
}

variable "users" {
  type    = list(number)
  default = []
}
