data "git_ignore" "current_ignored_items" {}

rule "must_be_true" "essential_ignored_items" {
  condition = length(compliment([
    "avmmakefile",
    "README-generated",
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
  ], data.git_ignore.current_ignored_items.records)) == 0
}

fix "git_ignore" "ensure_ignore" {
  rule_ids = [rule.must_be_true.essential_ignored_items.id]
  exist   = [
    "avmmakefile",
    "README-generated",
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