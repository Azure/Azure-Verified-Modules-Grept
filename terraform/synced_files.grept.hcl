locals {
  synced_files = toset([
    "CODE_OF_CONDUCT.md",
    "Makefile",
    "LICENSE",
    "SECURITY.md",
    "SUPPORT.md",
    ".terraform-docs.yml",
    ".github/workflows/e2e.yml",
    ".github/workflows/linting.yml",
    ".github/workflows/version-check.yml"
  ])
}

data "http" "synced_files" {
  for_each = local.synced_files

  url = "https://raw.githubusercontent.com/Azure/terraform-azurerm-avm-template/main/${each.value}"
}

rule "file_hash" "synced_files" {
  for_each = local.synced_files

  glob = each.value
  hash = sha1(data.http.synced_files[each.value].response_body)
}

fix "local_file" "synced_files" {
  for_each = local.synced_files

  rule_ids = [rule.file_hash.synced_files[each.value].id]
  paths    = [each.value]
  content  = data.http.synced_files[each.value].response_body
}