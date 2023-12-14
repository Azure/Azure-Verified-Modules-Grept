locals {
  essential_files = toset([
    "CODE_OF_CONDUCT.md",
    "Makefile",
    "LICENSE",
    "SECURITY.md",
    "SUPPORT.md",
    ".terraform-docs.yml",
  ])
}

data "http" "essential_files" {
  for_each = local.essential_files

  url = "https://raw.githubusercontent.com/Azure/terraform-azurerm-avm-template/main/${each.value}"
}

rule "file_hash" "essential_files" {
  for_each = local.essential_files

  glob = each.value
  hash = sha1(data.http.essential_files[each.value].response_body)
}

fix "local_file" "essential_files" {
  for_each = local.essential_files

  rule_ids = [rule.file_hash.essential_files[each.value].id]
  paths    = [each.value]
  content  = data.http.essential_files[each.value].response_body
}