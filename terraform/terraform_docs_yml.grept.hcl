# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tfnfr2---category-documentation---module-documentation-generation

data "http" "default_terraform_docs_yml" {
  url = "https://raw.githubusercontent.com/Azure/terraform-azurerm-avm-template/main/.terraform-docs.yml"
}

rule "must_be_true" terraform_docs_yml_exist {
  condition     = fileexists(".terraform-docs.yml")
  error_message = "A file called .terraform-docs.yml MUST be present in the root of the module"
}

fix "local_file" "default_terraform_docs_yml" {
  rule_ids = [rule.must_be_true.terraform_docs_yml_exist.id]
  paths   = [".terraform-docs.yml"]
  content = data.http.default_terraform_docs_yml.response_body
}