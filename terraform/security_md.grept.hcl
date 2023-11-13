data "http" "security_md" {
  url = "https://raw.githubusercontent.com/Azure/terraform-azurerm-avm-template/main/SECURITY.md"
}

rule "file_hash" "security_md_must_exist" {
  glob = "SECURITY.md"
  hash = sha1(data.http.security_md.response_body)
}

fix "local_file" "security_md" {
  rule_ids = [rule.file_hash.security_md_must_exist.id]
  paths    = ["SECURITY.md"]
  content  = data.http.security_md.response_body
}