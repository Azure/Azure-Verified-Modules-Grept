rule "dir_exist" "tests_dir_must_exist" {
  dir = "tests"
}

fix "local_file" "tests_dir_keep" {
  rule_ids = [rule.dir_exist.tests_dir_must_exist.id]
  paths    = ["tests/.gitkeep"]
  content  = ""
}