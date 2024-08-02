locals {
  rendered_tftest_yml = try(replace(data.http.e2e_yaml["tftest_yaml"].response_body, "[ self-hosted, 1ES.Pool=terraform-azurerm-avm-template ]", "[ self-hosted, 1ES.Pool=${local.pool_name} ]"), "")
}

data "http" "tftest_yaml" {
  for_each = contains(local.repo_urls_that_bypass_tftest_yml_sync, local.github_repository_url) ? [] : toset(["tftest_yaml"])

  request_headers = merge({}, local.common_http_headers)
  url             = "${local.url_prefix}/.github/workflows/terraform-test.yml"
}

rule "file_hash" "tftest_yaml" {
  for_each = contains(local.repo_urls_that_bypass_e2e_yml_sync, local.github_repository_url) ? [] : toset(["tftest_yaml"])

  precondition {
    condition     = local.github_repository_name_without_owner != "" && local.github_repository_name != ""
    error_message = "The followinng evironment variables must be set: Either GITHUB_REPOSITORY_OWNER or OVERRIDE_GITHUB_REPOSITORY_OWNER, and GITHUB_REPOSITORY or OVERRIDE_GITHUB_REPOSITORY."
  }

  glob = ".github/workflows/terraform-test.yml"
  hash = sha1(local.rendered_tftest_yml)
}

fix "local_file" "tftest_yaml" {
  for_each = contains(local.repo_urls_that_bypass_tftest_yml_sync, local.github_repository_url) ? [] : toset(["tftest_yaml"])

  rule_ids = [rule.file_hash.tftest_yaml[each.key].id]
  paths    = [rule.file_hash.tftest_yaml[each.key].glob]
  content  = local.rendered_tftest_yml
}
