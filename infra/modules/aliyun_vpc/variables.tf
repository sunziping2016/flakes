variable "cidr_block" {
  type = string
}

variable "vswitches" {
  type = map(object({
    zone_id = string
    netnum  = number
  }))
  default = {}
}
