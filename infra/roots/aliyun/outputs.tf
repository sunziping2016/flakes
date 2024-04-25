locals {
  nodes = [
    {
      hostname = "aliyun-hz0"
      ssh      = { host = "hz0.szp15.com" }
      arch     = "x86_64"
    },
    {
      hostname = "aliyun-hz1"
      ssh      = { host = "hz1.szp15.com" }
      arch     = "x86_64"
    }
  ]
}

resource "local_file" "nodes" {
  content  = jsonencode(local.nodes)
  filename = "../../generated/nodes.json"
}
