locals {
  override_modtm_config = <<-EOT
terraform {
  required_providers {
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
  }
}
EOT
}

rule "file_hash" "modtm_override" {
  glob = "terraform_override.tf"
  hash = sha1(local.override_modtm_config)
}

fix "local_file" "modtm_override" {
  rule_ids = [rule.file_hash.modtm_override.id]
  paths    = ["terraform_override.tf"]
  content  = local.override_modtm_config
}
