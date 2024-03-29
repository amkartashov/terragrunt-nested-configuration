# this file is to be included into each terragrunt.hcl with:
#
#    include "root" {
#      path   = find_in_parent_folders("root.hcl")
#      expose = true
#    }
#
#    locals {
#      cfg = include.root.locals.cfg
#    }
#

locals {
  ### BEGIN Read cfg.yaml files and merge

  # f.e. _cfg_dir_basenames = [ "", "prod", "ecs", "cluster" ]
  _cfg_dir_basenames = concat([""], split("/", path_relative_to_include()))

  # f.e. _cfg_files = [ 
  #   "../../../cfg.yaml",
  #   "../../../prod/cfg.yaml",
  #   "../../../prod/ecs/cfg.yaml",
  #   "../../../prod/ecs/cluster/cfg.yaml",
  #  ]
  _cfg_files = [for i, _ in local._cfg_dir_basenames :
    format("%s%s/cfg.yaml",
      ".",
      join("/", slice(local._cfg_dir_basenames, 0, i + 1))
    )
  ]

  cfg = merge([for cfg_file in local._cfg_files :
    try(yamldecode(file(cfg_file)), {})
  ]...)
  ### END Read cfg.yaml files and merge
}

generate "tg_output" {
  path      = "tg_output.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    output "tg_cfg" {
      value = ${jsonencode(local.cfg)}
    }
  EOF
}

terraform {
  source = "./"

  before_hook "echo stack name" {
    commands = ["apply", "plan", "output"]
    execute = [
      "echo", format("====== %s/%s",
        local.cfg.environment,
        local.cfg.stack_name,
      )
    ]
  }
}
