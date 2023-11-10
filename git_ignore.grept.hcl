data "git_ignore" "current_ignored_items" {}

rule "must_be_true" "essential_ignored_items" {
  condition = length(setintersection(toset([
    "**/.terraform/*",
    "*.tfstate",
    "*.tfstate.*",
    "crash.log",
    "crash.*.log",
    "*.tfvars",
    "*.tfvars.json",
    "override.tf",
    "override.tf.json",
    "*_override.tf",
    "*_override.tf.json",
    ".terraform.lock.hcl",
    ".terraformrc",
    "terraform.rc",
  ]), toset(data.git_ignore.current_ignored_items.records))) == length([
    "**/.terraform/*",
    "*.tfstate",
    "*.tfstate.*",
    "crash.log",
    "crash.*.log",
    "*.tfvars",
    "*.tfvars.json",
    "override.tf",
    "override.tf.json",
    "*_override.tf",
    "*_override.tf.json",
    ".terraform.lock.hcl",
    ".terraformrc",
    "terraform.rc",
  ])
}

fix "git_ignore" "ensure_ignore" {
  rule_id = rule.must_be_true.essential_ignored_items.id
  exist   = [
    "**/.terraform/*",
    "*.tfstate",
    "*.tfstate.*",
    "crash.log",
    "crash.*.log",
    "*.tfvars",
    "*.tfvars.json",
    "override.tf",
    "override.tf.json",
    "*_override.tf",
    "*_override.tf.json",
    ".terraform.lock.hcl",
    ".terraformrc",
    "terraform.rc",
  ]
}