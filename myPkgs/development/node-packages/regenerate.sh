#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

set -eu -o pipefail

rm -f node-env.nix
node2nix -i node-packages-editthis.json -o node-packages.nix -c default.nix
