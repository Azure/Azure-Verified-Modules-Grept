locals {
  url_prefix        = "https://raw.githubusercontent.com/Azure/terraform-azurerm-avm-template/main"
  github_server_url = coalesce(env("GITHUB_SERVER_URL"), "https://github.com")
  # Azure/xxx
  github_repository_name = try(coalesce(env("OVERRIDE_GITHUB_REPOSITORY") ,env("GITHUB_REPOSITORY")), "")
  # Azure
  github_repository_owner              = try(coalesce(env("OVERRIDE_GITHUB_REPOSITORY_OWNER"), env("GITHUB_REPOSITORY_OWNER")), "")
  github_repository_name_without_owner = trimprefix(local.github_repository_name, "${local.github_repository_owner}/")
  github_repository_url                = "${local.github_server_url}/${local.github_repository_name}"
}
