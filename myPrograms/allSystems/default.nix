{ pkgs, lib ? pkgs.lib, ... }:

{
  imports = [ ./mailcap ./my-tuir ./my-vim ./passff ];
}
