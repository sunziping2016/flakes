variable "vpc_id" {
  type    = string
  default = null
}

variable "rules" {
  type = map(object({
    type         = optional(string, "ingress")
    ip_protocol  = optional(string, "tcp")
    port_range   = optional(string)
    cidr_ip      = optional(string)
    ipv6_cidr_ip = optional(string)
  }))
  default = {}
}
