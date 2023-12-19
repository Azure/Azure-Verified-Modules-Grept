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
  url_prefix = "https://raw.githubusercontent.com/Azure/terraform-azurerm-avm-template/main"
  github_repository_name = env("GITHUB_REPOSITORY")
  github_repository_owner = env("GITHUB_REPOSITORY_OWNER")
  github_repository_name_without_owner = trimprefix(local.github_repository_name, "${local.github_repository_owner}/")
  rendered_e2e_yml = replace(data.http.e2e_yaml.response_body, "[ self-hosted, 1ES.Pool=terraform-azurerm-container-apps ]", "[ self-hosted, 1ES.Pool=${local.github_repository_name_without_owner} ]")
}

data "http" "synced_files" {
  for_each = local.synced_files

  url = "${local.url_prefix}/${each.value}"
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

data "http" "e2e_yaml" {
  url = "${local.url_prefix}/.github/workflows/e2e.yml"
}

rule "file_hash" "e2e_yaml" {
  glob = ".github/workflows/e2e.yml"
  hash = sha1(local.rendered_e2e_yml)
}

fix "local_file" "e2e_yaml" {
  rule_ids = [rule.file_hash.e2e_yaml.id]
  paths    = [rule.file_hash.e2e_yaml.glob]
  content  = local.rendered_e2e_yml
}