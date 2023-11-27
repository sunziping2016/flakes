variable "vpc_id" {
  type = string
}

variable "vswitch_id" {
  type = string
}

variable "forward_entries" {
  type = map(object({
    ip_protocol   = optional(string, "tcp")
    external_port = number
    internal_port = number
    internal_ip   = string
  }))
  default = {}
}
