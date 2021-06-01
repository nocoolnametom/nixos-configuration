{ pkgs, lib ? pkgs.lib, ... }:

{
  imports = [ ./mailcap ./my-vim ./passff ];
}
