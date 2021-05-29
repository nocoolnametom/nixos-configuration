{ pkgs, lib ? pkgs.lib, ... }:

{
  imports = [ ./my-i3status-rust ];
}
