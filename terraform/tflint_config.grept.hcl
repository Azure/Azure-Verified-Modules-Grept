data "http" tflint_hcl {
  url = "https://raw.githubusercontent.com/Azure/terraform-azurerm-avm-template/main/.tflint.hcl"
}

data "http" tflint_example_hcl {
  url = "https://raw.githubusercontent.com/Azure/terraform-azurerm-avm-template/main/.tflint_example.hcl"
}

rule "file_hash" "tflint_hcl" {
  glob = ".tflint.hcl"
  hash = sha1(data.http.tflint_hcl.response_body)
}

rule "file_hash" "tflint_example_hcl" {
  glob = ".tflint_example.hcl"
  hash = sha1(data.http.tflint_example_hcl.response_body)
}

fix "local_file" "tflint_hcl" {
  rule_ids = [rule.file_hash.tflint_hcl.id]
  paths    = [rule.file_hash.tflint_hcl.glob]
  content  = data.http.tflint_hcl.response_body
}

fix "local_file" "tflint_example_hcl" {
  rule_ids = [rule.file_hash.tflint_example_hcl.id]
  paths    = [rule.file_hash.tflint_example_hcl.glob]
  content  = data.http.tflint_example_hcl.response_body
}
