data "http" "avm_res_module_csv" {
  request_headers = merge({}, local.common_http_headers)
  url      = "https://raw.githubusercontent.com/Azure/Azure-Verified-Modules/main/docs/static/module-indexes/TerraformResourceModules.csv"
}

data "http" "avm_ptn_module_csv" {
  request_headers = merge({}, local.common_http_headers)
  url      = "https://raw.githubusercontent.com/Azure/Azure-Verified-Modules/main/docs/static/module-indexes/TerraformPatternModules.csv"
}

locals {
  all_avm_tf_modules = { for obj in concat(csvdecode(data.http.avm_res_module_csv.response_body), csvdecode(data.http.avm_ptn_module_csv.response_body)) : obj.RepoURL => obj }
  current_module = local.all_avm_tf_modules["${local.github_repository_url}"]
}

data "github_repository_collaborators" this {
  owner = local.github_repository_owner
  repo_name = local.github_repository_name_without_owner
}

data "github_repository_teams" this {
  owner = local.github_repository_owner
  repo_name = local.github_repository_name_without_owner
}

rule "must_be_true" no_personal_collaborators {
    condition = length(data.github_repository_collaborators.this.users) == 0
    error_message = "No personal collaborators are allowed. Only teams are allowed."
}

fix "github_repository_collaborators" no_personal_collaborators {
  rule_ids = [rule.must_be_true.no_personal_collaborators.id]
  owner = local.github_repository_owner
  repo_name = local.github_repository_name_without_owner
}

locals {
  wanted_repository_team = {
    module_contributors = {
        name = "${local.current_module.ModuleName}-module-contributors-tf",
        members = [local.current_module.PrimaryModuleOwnerGHHandle],
        permission = "push",
    }
    module_owners = {
        name = "${local.current_module.ModuleName}-module-owners-tf",
        members = [local.current_module.PrimaryModuleOwnerGHHandle],
        permission = "admin",
    }
  }
  wanted_avm_team = {
    avm_core_team_technical = {
      name = "avm-core-team-technical-terraform"
      permission = "admin"
    }
    azurecla-write = {
      name = "azurecla-write"
      permission = "push"
    }
    security = {
      name = "security"
      permission = "pull"
    }
    terraform-avm = {
      name = "terraform-avm"
      permission = "admin"
    }
  }
}

data "github_team" repository_team {
  for_each = local.wanted_repository_team
  owner = local.github_repository_owner
  slug = each.value.name
}

rule "must_be_true" repository_teams {
  for_each = local.wanted_repository_team
  condition = data.github_team.repository_team[each.key].team_name != null && data.github_team.repository_team[each.key].team_name != ""
  error_message = "No ${each.key} team found. Need to create a team with the name ${each.value.name}."
}

fix "github_team" repository_teams {
  for_each = local.wanted_repository_team
  rule_ids = [rule.must_be_true.repository_teams[each.key].id]
  owner = local.github_repository_owner
  team_name = each.value.name
  description = "${each.key} for ${local.current_module.ModuleName} module."
  privacy = "closed"
}

fix "github_team_members" repository_team_members {
  for_each = local.wanted_repository_team
  rule_ids = [rule.must_be_true.repository_teams[each.key].id]
  owner = local.github_repository_owner
  team_slug = each.value.name
  dynamic "member" {
    for_each = each.value.members
    content {
      username = member.value
      role = "maintainer"
    }
  }
  depends_on = [fix.github_team.repository_teams]
}

rule "must_be_true" repository_teams_attached {
  for_each = local.wanted_repository_team
  condition = length([ for team in data.github_repository_teams.this.teams : team if team.name == each.value.name && team.permission == each.value.permission ]) == 1
  error_message = "No ${each.key} team with expected permission ${each.value.permission} found. Need to add the team ${each.value.name} to the repository with the permissions ${each.value.permission}."
}

fix "github_team_repository" this {
  rule_ids = [ for k, r in merge(rule.must_be_true.repository_teams_attached, rule.must_be_true.avm_teams_attached) : r.id ]
  owner = local.github_repository_owner
  repo_name = local.github_repository_name_without_owner
  dynamic "team" {
    for_each = local.wanted_repository_team
    content {
      team_slug = team.value.name
      permission = team.value.permission
    }
  }
  dynamic "team" {
    for_each = local.wanted_avm_team
    content {
      team_slug = team.value.name
      permission = team.value.permission
    }
  }
}

rule "must_be_true" avm_teams_attached {
  for_each = local.wanted_avm_team
  condition = length([ for team in data.github_repository_teams.this.teams : team if team.name == each.value.name && team.permission == each.value.permission ]) == 1
  error_message = "No ${each.key} team with expected permission ${each.value.permission} found. Need to add the team ${each.value.name} to the repository with the permissions ${each.value.permission}."
}

