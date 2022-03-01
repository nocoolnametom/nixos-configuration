{ pkgs, lib ? pkgs.lib, ... }:

rec {
  ciServerUrl = "ci.example.com";
  npmRegistryUrl = "npm.example.com";
  jiraUrl = "jira.example.com";
  orgUrl = "examplecorp.com";
  orgBrandUrl = "example.com";
  orgName = "Example Corp";
  orgShortName = "Example";
  oktaOrgFullName = "Example Corp, Inc.";
  oldBrand = "Sample";
  oldBrandStagingDomain = "host.stage.sample.com";
  currentBrandStagingDomain = "stage.sample-amazon.com";
  currentBrandProdServicesDomain = "prod.sample-amazon.com";
  currentBrand = "Posited";
  currentDepartment = "PositedPlatform";
  gitServer = "git.example.com";
  oldGitServer = "stash.${oldBrandUrl}";
  reallyOldGitServer = "stash.${oldBrandStagingDomain}";
  oldGitPort = 80;
  userName = "tdoggett";
  emailAddress = "${userName}@${orgUrl}";
  oauthClientId = "foo-bar";
  oauthTenantId = "foo-bar";
  intelephenseKey = "YourKeyHere!";
  protonmailBridgePassword = "Protonmail!";
  workVpnName = "Work\ VPN";
  workVpnUrl = "loc.vpn.examplecorp.com";
}
