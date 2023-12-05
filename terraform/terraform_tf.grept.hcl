rule "must_be_true" "terraform_tf_must_exist" {
  condition     = fileexists("terraform.tf")
  error_message = "there must be a `terraform.tf` file."
}

fix "local_file" "terraform_tf" {
  rule_ids = [rule.must_be_true.terraform_tf_must_exist.id]
  paths    = ["terraform.tf"]
  content  = ""
}