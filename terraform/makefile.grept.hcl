data "http" makefile {
  url = "https://raw.githubusercontent.com/Azure/terraform-azurerm-avm-template/main/Makefile"
}

rule "file_hash" "makefile" {
  glob = "Makefile"
  hash = sha1(data.http.makefile.response_body)
}

fix "local_file" "makefile" {
  rule_ids = [rule.file_hash.makefile.id]
  paths    = ["Makefile"]
  content  = data.http.makefile.response_body
}