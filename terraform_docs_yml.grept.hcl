# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tfnfr2---category-documentation---module-documentation-generation

data "http" "default_terraform_docs_yml" {
  url = "https://raw.githubusercontent.com/Azure/terraform-azurerm-avm-template/main/.terraform-docs.yml"
}

rule "must_be_true" terraform_docs_yml_exist {
  condition     = fileexists(".terraform-docs.yml")
  error_message = "A file called .terraform-docs.yml MUST be present in the root of the module"
}

fix "local_file" "default_terraform_docs_yml_on_absent" {
  rule_id = rule.must_be_true.terraform_docs_yml_exist.id
  paths   = [".terraform-docs.yml"]
  content = data.http.default_terraform_docs_yml.response_body
}

rule "must_be_true" terraform_docs_yml_syntax_valid {
  condition     = can(yamldecode(file(".terraform-docs.yml")))
  error_message = "Cannot decode `.terraform-docs.yml` file successfully."
}

fix "local_file" "default_terraform_docs_yml_on_decode_failure" {
  rule_id = rule.must_be_true.terraform_docs_yml_syntax_valid.id
  paths   = [".terraform-docs.yml"]
  content = data.http.default_terraform_docs_yml.response_body
}