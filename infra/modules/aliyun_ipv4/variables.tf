variable "vpc_id" {
  type = string
}

variable "vpc_route_table_id" {
  type = string
}

variable "instance_ids" {
  type    = map(string)
  default = {}
}
