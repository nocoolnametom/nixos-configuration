# This is my NixOS configuration repo

It is meant around being useful for multiple machines.  Link the `*.dist.nix` files to their respective locations, use the regular `configuration.nix` and `home.nix` files to try things out, but since they're not under version control try to move everything in them either to the distributed files or make a hostname-controlled configuration in a service/program settings wrapper.

Also, note that this project does not contain any keys (they go within `myKeys/private`), work information (copy `workInfo_example.nix` and replace the placeholders with work information), or work repos (they will be pulled down as part of the list of personal repos and can then be referenced using the `work_repos` command-line script).
