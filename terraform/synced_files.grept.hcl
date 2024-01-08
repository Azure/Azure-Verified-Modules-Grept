locals {
  synced_files = toset([
    "_footer.md",
    ".github/CODEOWNERS",
    ".github/policies/avmrequiredfiles.yml",
    ".github/workflows/linting.yml",
    ".github/workflows/version-check.yml",
    ".terraform-docs.yml",
    "avm.bat",
    "CODE_OF_CONDUCT.md",
    "examples/.terraform-docs.yml",
    "LICENSE",
    "Makefile",
    "SECURITY.md",
  ])
}

data "http" "synced_files" {
  for_each = local.synced_files

  request_headers = merge({}, local.common_http_headers)
  url             = "${local.url_prefix}/${each.value}"
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
