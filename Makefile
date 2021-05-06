SHELL=/usr/bin/env bash

ifeq ($(__NIXOS_SET_ENVIRONMENT_DONE),1)
link:
	[[ -e /etc/nixos/configuration.nix && ! -L /etc/nixos/configuration.nix ]] && \
	  sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak || exit 0;
	[[ ! -e /etc/nixos/configuration.nix ]] && sudo ln -s `readlink -f configuration.dist.nix` /etc/nixos/configuration.nix || \
	exit 0;
else ifeq ($(__NIX_DARWIN_SET_ENVIRONMENT_DONE),1)
link:
	[[ -e ~/.nixpkgs/darwin-configuration.nix && ! -L ~/.nixpkgs/darwin-configuration.nix ]] && \
	   mv ~/.nixpkgs/darwin-configuration.nix ~/.nixpkgs/darwin-configuration.nix.bak || exit 0;
	mkdir -p ~/.nixpkgs;
	[[ ! -e ~/.nixpkgs/darwin-configuration.nix ]] && ln -s `readlink -f darwin-configuration.nix` ~/.nixpkgs/darwin-configuration.nix || \
		exit 0;
else
link:
	[[ -e ~/.nixpkgs/home.nix && ! -L ~/.nixpkgs/home.nix ]] && \
	   mv ~/.nixpkgs/home.nix ~/.nixpkgs/home.nix.bak || exit 0;
	mkdir -p ~/.nixpkgs;
	[[ ! -e ~/.nixpkgs/home.nix ]] && ln -s `readlink -f home.dist.nix` ~/.nixpkgs/home.nix || \
		exit 0;
endif