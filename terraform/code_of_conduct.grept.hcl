data "http" "code_of_conduct" {
  url = "https://raw.githubusercontent.com/Azure/terraform-azurerm-avm-template/main/CODE_OF_CONDUCT.md"
}

rule "file_hash" "code_of_conduct" {
  glob = "CODE_OF_CONDUCT.md"
  hash = sha1(data.http.code_of_conduct.response_body)
}

fix "local_file" "code_of_conduct" {
  rule_ids = [rule.file_hash.code_of_conduct.id]
  paths    = ["CODE_OF_CONDUCT.md"]
  content  = data.http.code_of_conduct.response_body
}