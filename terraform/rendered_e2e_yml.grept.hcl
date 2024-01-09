locals {
  pool_name = length(local.github_repository_name_without_owner) >= 45 ? sha1(local.github_repository_name_without_owner) : local.github_repository_name_without_owner
  rendered_e2e_yml = try(replace(data.http.e2e_yaml["e2e_yaml"].response_body, "[ self-hosted, 1ES.Pool=terraform-azurerm-avm-template ]", "[ self-hosted, 1ES.Pool=${local.pool_name} ]"), "")
}

data "http" "e2e_yaml" {
  for_each = contains(local.repo_urls_that_bypass_e2e_yml_sync, local.github_repository_url) ? [] : toset(["e2e_yaml"])

  request_headers = merge({}, local.common_http_headers)
  url             = "${local.url_prefix}/.github/workflows/e2e.yml"
}

rule "file_hash" "e2e_yaml" {
  for_each = contains(local.repo_urls_that_bypass_e2e_yml_sync, local.github_repository_url) ? [] : toset(["e2e_yaml"])

  precondition {
    condition     = local.github_repository_name_without_owner != "" && local.github_repository_name != ""
    error_message = "The followinng evironment variables must be set: Either GITHUB_REPOSITORY_OWNER or OVERRIDE_GITHUB_REPOSITORY_OWNER, and GITHUB_REPOSITORY or OVERRIDE_GITHUB_REPOSITORY."
  }

  glob = ".github/workflows/e2e.yml"
  hash = sha1(local.rendered_e2e_yml)
}

fix "local_file" "e2e_yaml" {
  for_each = contains(local.repo_urls_that_bypass_e2e_yml_sync, local.github_repository_url) ? [] : toset(["e2e_yaml"])

  rule_ids = [rule.file_hash.e2e_yaml[each.key].id]
  paths    = [rule.file_hash.e2e_yaml[each.key].glob]
  content  = local.rendered_e2e_yml
}
