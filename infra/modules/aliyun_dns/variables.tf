variable "domain" {
  description = "The name of domain."
  type        = string
}

variable "records" {
  description = "The records of domain."
  type = map(object({
    host_record = string
    type        = string
    value       = string
    ttl         = optional(number, 600)
    priority    = optional(number)
  }))
  default = {}
}
