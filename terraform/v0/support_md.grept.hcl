data "http" "support_md" {
  url = "https://raw.githubusercontent.com/Azure/terraform-azurerm-avm-template/main/SUPPORT.md"
}

rule "must_be_true" "support_md_must_exist" {
  condition     = fileexists("SUPPORT.md")
  error_message = "there must be a `SUPPORT.md` file."
}

fix "local_file" "support_md" {
  rule_ids = [rule.must_be_true.support_md_must_exist.id]
  paths    = ["SUPPORT.md"]
  content  = data.http.support_md.response_body
}