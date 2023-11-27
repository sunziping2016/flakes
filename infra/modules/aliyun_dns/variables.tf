variable "domain" {
  type = string
}

variable "records" {
  type = map(object({
    host_record = string
    type        = string
    value       = string
    ttl         = optional(number, 600)
    priority    = optional(number)
  }))
  default = {}
}
