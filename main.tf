locals {
  name = "${replace(var.repository, "/", "-")}-${var.branch}"
  
}

data "tfe_organization" "org" {
  name = var.tfe_org
}

resource "tfe_oauth_client" "oauth" {
  count            = length(var.oauth_token_id) > 0 ? 0 : 1
  name             = local.name
  organization     = data.tfe_organization.org.name
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.gh_token
  service_provider = "github"
}

resource "tfe_workspace" "workspace" {
  name         = local.name
  organization = data.tfe_organization.org.name
  vcs_repo {
    identifier     = var.repository
    branch         = var.branch
    oauth_token_id = length(var.oauth_token_id) > 0 ? var.oauth_token_id : tfe_oauth_client.oauth[0].oauth_token_id
  }
  depends_on = [
      tfe_oauth_client.oauth,
  ]
}