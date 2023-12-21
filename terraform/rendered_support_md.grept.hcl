locals {
  rendered_support_md = try(replace(data.http.support_md.response_body, "[issues here](https://github.com/Azure/terraform-azurerm-avm-template/issues)", "[issues here](https://github.com/${local.github_repository_name}/issues)"), "")
}

data "http" "support_md" {
  url = "${local.url_prefix}/SUPPORT.md"
}

rule "file_hash" "support_md" {
  glob = "SUPPORT.md"
  hash = sha1(local.rendered_support_md)
}

fix "local_file" "support_md" {
  rule_ids = [rule.file_hash.support_md.id]
  paths    = [rule.file_hash.support_md.glob]
  content  = local.rendered_support_md
}
