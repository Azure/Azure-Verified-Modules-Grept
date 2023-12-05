rule "dir_exist" "examples_dir_must_exist" {
  dir = "examples"
}

fix "local_file" "examples_dir_keep" {
  rule_ids = [rule.dir_exist.examples_dir_must_exist.id]
  paths    = ["examples/.gitkeep"]
  content  = ""
}