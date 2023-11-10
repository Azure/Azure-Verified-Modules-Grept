data "http" mit_license {
  url = "https://raw.githubusercontent.com/Azure/Azure-Verified-Modules/main/LICENSE"
}

rule "file_hash" "mit_license" {
  glob          = "LICENSE"
  hash          = sha1(data.http.mit_license.response_body)
  error_message = "[MIT license](https://raw.githubusercontent.com/Azure/Azure-Verified-Modules/main/LICENSE) is required."
}

fix "local_file" "mit_license" {
  rule_id = rule.file_hash.mit_license.id
  paths   = ["LICENSE"]
  content = data.http.mit_license.response_body
}