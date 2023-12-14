locals {
  must_exist_files = tomap({
    "main.tf": "",
    "variables.tf": ""
    "outputs.tf": ""
    "terraform.tf": ""
    "locals.version.tf.json": jsonencode({
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