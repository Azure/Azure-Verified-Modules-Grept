rule "must_be_true" "output_tf_should_not_exist" {
  condition     = !fileexists("output.tf")
  error_message = "file name should be `outputs.tf` rather than `output.tf`."
}

fix "rename_file" "output_tf_to_outputs_tf" {
  rule_ids = [rule.must_be_true.output_tf_should_not_exist.id]
  old_name = "output.tf"
  new_name = "outputs.tf"
}

rule "must_be_true" "outputs_tf_must_exist" {
  condition     = fileexists("output.tf")/*leave to output_tf_should_not_exist rule*/ || fileexists("outputs.tf")
  error_message = "there must be a `outputs.tf` file."
}

fix "local_file" "outputs_tf" {
  rule_ids = [rule.must_be_true.outputs_tf_must_exist.id]
  paths    = ["outputs.tf"]
  content  = ""
}