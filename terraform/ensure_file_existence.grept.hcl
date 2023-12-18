locals {
  must_exist_files = tomap({
    "main.tf" : "",
    "terraform.tf" : ""
    "locals.version.tf.json" : jsonencode({
      locals = {
        module_version = "0.1.0"
      }
    })
  })
}

rule "must_be_true" "file_existence" {
  for_each = local.must_exist_files

  condition     = fileexists(each.key)
  error_message = "there must be a `${each.key}` file."
}

fix "local_file" "file_existence" {
  for_each = local.must_exist_files

  rule_ids = [rule.must_be_true.file_existence[each.key].id]
  paths    = [each.key]
  content  = each.value
}

rule "must_be_true" "variables_tf_exist" {
  condition     = fileexists("variables.tf") && !fileexists("variable.tf") # leave variable.tf to the rename fix
  error_message = "there must be a variables.tf file."
}

fix "local_file" "variables_tf" {
  rule_ids = [rule.must_be_true.variables_tf_exist.id]
  paths   = ["variables.tf"]
  content = ""
}

rule "must_be_true" "outputs_tf_exist" {
  condition     = fileexists("outputs.tf") && !fileexists("output.tf") # leave output.tf to the rename fix
  error_message = "there must be a outputs.tf file."
}

fix "local_file" "outputs_tf" {
  rule_ids = [rule.must_be_true.outputs_tf_exist.id]
  paths   = ["outputs.tf"]
  content = ""
}
