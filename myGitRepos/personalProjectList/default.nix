{ shells, ... }:

{
  gitlab = {
    nocoolnametom = [
      { repo = "journalofdiscourses"; }
      { repo = "lds-beacon-pages"; }
      { repo = "mormoncanon"; }
      { repo = "mormonquotes"; }
    ];
  };
  github = {
    atlassian = [{ repo = "koa-oas3"; }];
    facebook = [{ repo = "create-react-app"; }];
    LnL7 = [ { repo = "nix-darwin"; } { repo = "nix-docker"; } ];
    nocoolnametom = [
      { repo = "workProjectList"; } # This enables `work_repos` to know what to clone
      { repo = "nixos-configuration"; } # This is the current repo
      { repo = "cesletter"; }
      { repo = "cesletterbox"; }
      { repo = "home-assistant-config"; }
      { repo = "kids-bank-box"; }
      { repo = "nixos-linode"; }
      { repo = "nix-configs"; }
      { repo = "OpenMicNight"; }
      { repo = "wiki_copy"; }
      { repo = "koa-oas3"; }
      { repo = "foam"; }
    ];
    nix-community = [{ repo = "home-manager"; }];
    skidding = [{ repo = "jobs-done"; }];
    target = [{ repo = "lorri"; }];
  };
}
