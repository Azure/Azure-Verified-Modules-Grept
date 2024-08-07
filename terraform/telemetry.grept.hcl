# re-render the telemetry file to use azapi_client_config instead of azurerm_client_config
locals {
  telemetry_azapi_content   = try(replace(data.http.main_telemetry.response_body, "azurerm_client_config", "azapi_client_config"), "")
  azurerm_provider_declared = try(strcontains(file("terraform.tf"), "source  = \"hashicorp/azurerm\""), false)
}

# get the reference telemetry file
data "http" "main_telemetry" {
  request_headers = merge({}, local.common_http_headers)
  url             = "${local.url_prefix}/main.telemetry.tf"
}

# Local file must use either azurerm_client_config or azapi_client_config
rule "must_be_true" "main_telemetry" {
  condition     = sha1(file("main.telemetry.tf")) == sha1(data.http.main_telemetry.response_body) || sha1(file("main.telemetry.tf")) == sha1(local.telemetry_azapi_content)
  error_message = "The main.telemetry.tf file must be present in the repository."
}

# Default to azurerm_client_config for the fix
fix "local_file" "main_telemetry" {
  rule_ids = [rule.must_be_true.main_telemetry.id]
  paths    = ["main.telemetry.tf"]
  content  = local.azurerm_provider_declared ? data.http.main_telemetry.response_body : local.telemetry_azapi_content
}
