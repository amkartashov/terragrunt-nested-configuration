# terragrunt-nested-configuration

*Example of nested configuration in repo with terragrunt stacks organized in tree*.

`cfg.yaml` files are merged. F.e. for stack defined in `env/prod/ecs/cluster/terragrunt.hcl`, terragrunt will try to read and merge files `env/cfg.yaml`, `env/prod/cfg.yaml`, `env/prod/ecs/cfg.yaml`, `env/prod/ecs/cluster/cfg.yaml`.

Merging logic is defined in `env/root.hcl` which should be *include*d each into `terragrunt.hcl` file with this code:

```hcl
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  cfg = include.root.locals.cfg
}
```

Note that this example uses `merge()` function which [does not do deep merging](https://github.com/hashicorp/terraform/issues/24987), so it's not possible to merge complex configurations. This simple solutions is mostly suitable for simple flat key-value configurations.

## Demo

```
$ export TERRAGRUNT_NON_INTERACTIVE=true
$ terragrunt run-all init >/dev/null 2>&1
$ terragrunt run-all apply -auto-approve >/dev/null 2>&1
$ terragrunt --terragrunt-parallelism 1 run-all output 2>/dev/null
====== staging/ecs/cluster
tg_cfg = {
  "aws_account_id" = "234567890123"
  "aws_account_name" = "stg-account"
  "aws_region" = "eu-west-1"
  "environment" = "staging"
  "stack_description" = "AWS ECS cluster"
  "stack_name" = "ecs/cluster"
}
====== production/ecs/cluster
tg_cfg = {
  "aws_account_id" = "123456789012"
  "aws_account_name" = "prod-account"
  "aws_region" = "eu-west-1"
  "environment" = "production"
  "stack_description" = "AWS ECS cluster"
  "stack_name" = "ecs/cluster"
}
====== staging/ecs/tasks
tg_cfg = {
  "aws_account_id" = "234567890123"
  "aws_account_name" = "stg-account"
  "aws_region" = "eu-west-1"
  "environment" = "staging"
  "stack_description" = "AWS ECS cluster tasks"
  "stack_name" = "ecs/tasks"
}
====== staging/network
tg_cfg = {
  "aws_account_id" = "234567890123"
  "aws_account_name" = "stg-account"
  "aws_region" = "eu-west-1"
  "environment" = "staging"
  "stack_description" = "AWS VPC and subnets"
  "stack_name" = "network"
}
====== production/ecr
tg_cfg = {
  "aws_account_id" = "123456789012"
  "aws_account_name" = "prod-account"
  "aws_region" = "eu-west-1"
  "environment" = "production"
  "stack_description" = "AWS ECR private repositories"
  "stack_name" = "ecr"
}
====== production/network
tg_cfg = {
  "aws_account_id" = "123456789012"
  "aws_account_name" = "prod-account"
  "aws_region" = "eu-west-1"
  "environment" = "production"
  "stack_description" = "AWS VPC and subnets"
  "stack_name" = "network"
}
====== production/ecs/tasks
tg_cfg = {
  "aws_account_id" = "123456789012"
  "aws_account_name" = "prod-account"
  "aws_region" = "eu-west-1"
  "environment" = "production"
  "stack_description" = "AWS ECS cluster tasks"
  "stack_name" = "ecs/tasks"
}
====== staging/ecr
tg_cfg = {
  "aws_account_id" = "234567890123"
  "aws_account_name" = "stg-account"
  "aws_region" = "eu-west-1"
  "environment" = "staging"
  "stack_description" = "AWS ECR private repositories"
  "stack_name" = "ecr"
}
```
