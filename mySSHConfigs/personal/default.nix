{ pkgs ? (import <nixpkgs> { }), lib ? pkgs.lib
  # When sending in the path to the private key make sure it's a string!
  # try referencing the file by path once via something like
  # idRsa = if lib.pathExists ../idRsa then toString ../idRsa else ""
, idRsa ? "", ... }:

{ } // (lib.optionalAttrs (idRsa != "") {
  gitlab = {
    host = "gitlab";
    hostname = "gitlab.com";
    identityFile = idRsa;
    user = "git";
  };
  github = {
    host = "github";
    hostname = "github.com";
    identityFile = idRsa;
    user = "git";
  };
  remote_gollum = {
    host = "remote_gollum";
    hostname = "home.nocoolnametom.com";
    identityFile = idRsa;
    user = "pi";
    port = 22223;
  };
  remote_bert = {
    host = "remote_bert";
    hostname = "home.nocoolnametom.com";
    identityFile = idRsa;
    user = "tdoggett";
    port = 22224;
  };
  linode = {
    host = "linode";
    hostname = "72.14.183.148";
    identityFile = idRsa;
    user = "root";
    port = 2222;
  };
  elrond = {
    host = "elrond";
    hostname = "45.33.53.132";
    identityFile = idRsa;
    user = "root";
    port = 2222;
  };
  bert = {
    host = "bert";
    hostname = "192.168.0.20";
    identityFile = idRsa;
    user = "tdoggett";
  };
  pippin = {
    host = "pippin";
    hostname = "192.168.0.22";
    identityFile = idRsa;
    user = "pi";
  };
  shirriff = {
    host = "shirriff";
    hostname = "192.168.0.8";
    identityFile = idRsa;
    user = "pi";
  };
  gollum = {
    host = "gollum";
    hostname = "192.168.0.23";
    identityFile = idRsa;
    user = "pi";
  };
})

