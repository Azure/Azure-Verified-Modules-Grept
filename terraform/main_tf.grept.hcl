rule "must_be_true" "main_tf_must_exist" {
  condition     = fileexists("main.tf")
  error_message = "there must be a `main.tf` file."
}

fix "local_file" "main_tf" {
  rule_ids = [rule.must_be_true.main_tf_must_exist.id]
  paths    = ["main.tf"]
  content  = ""
}