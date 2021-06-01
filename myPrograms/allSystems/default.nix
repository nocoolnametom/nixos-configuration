{ pkgs, lib ? pkgs.lib, ... }:

{
  imports = [ ./mailcap ./my-newsboat ./my-tuir ./my-vim ./passff ];
}
