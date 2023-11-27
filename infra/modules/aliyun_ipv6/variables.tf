variable "vpc_id" {
  type = string
}

# Currently, Aliyun only supports binding IPv6 addresses to ECS instances.
variable "instance_ids" {
  type    = map(string)
  default = {}
}
