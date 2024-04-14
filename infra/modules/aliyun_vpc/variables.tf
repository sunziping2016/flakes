variable "cidr_block" {
  type = string
}

variable "vswitch_newbits" {
  type    = number
  default = 6
}

variable "vswitches" {
  type = map(object({
    zone_id = string
    netnum  = number
  }))
  default = {}
}
