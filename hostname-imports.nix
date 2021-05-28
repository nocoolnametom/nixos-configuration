{ pkgs, lib ? pkgs.lib, hostName }:

# This is just to load some pre-selected hardware options
# for specific machines.  You shouldn't have to make changes
# to this usually...

[ ] ++ (lib.optionals (hostName == "lappy") [
  "${
    builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }
  }/lenovo/thinkpad/x1-extreme"
])
