locals {
  repo_urls_that_bypass_e2e_yml_sync = toset([
    "https://github.com/Azure/terraform-azurerm-avm-res-authorization-roleassignment", # needs access at higher scopes than subscription
    "https://github.com/Azure/terraform-azurerm-avm-ptn-alz",                          # needs access at higher scopes than subscription
  ])
}
