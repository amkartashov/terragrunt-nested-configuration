include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  cfg = include.root.locals.cfg
}

