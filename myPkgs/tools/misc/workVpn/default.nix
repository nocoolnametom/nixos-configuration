{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, stdenv ? pkgs.stdenv, username ?
  "user"
  # This is the name of the entry for pass
, passName ? "example.okta.com/${username}"
  # This is the name of the VPN in Linux Network Manager
, vpnName ? "Brand VPN"
  # The URL for the VPN for use on MacOS
, vpnUrl ? "vpn.example.com"
  # The command to spawn that we will use expect to run through to connect to the VPN
, spawnCommand ? if stdenv.isDarwin then
  "/opt/cisco/anyconnect/bin/vpn connect ${vpnUrl}"
else
  "nmcli c up ${lib.escape [ " " ] vpnName} --ask", ... }:

let
  passPackage = pkgs.pass.withExtensions
    (exts: [ exts.pass-genphrase exts.pass-update exts.pass-otp ]);
  otpRequest = if stdenv.isDarwin then "Answer:" else "Response:";
  workVpnPass = pkgs.writeShellScriptBin "workVpnPass" ''
    ${passPackage}/bin/pass ${passName} | ${pkgs.coreutils}/bin/head -1
  '';
  workVpnOtp = pkgs.writeShellScriptBin "workVpnOtp" ''
    ${passPackage}/bin/pass otp ${passName} | ${pkgs.coreutils}/bin/head -1
  '';
in pkgs.writeScriptBin "workVpn" ''
  #!${pkgs.expect}/bin/expect -f

  set username "${username}";
  set password [ exec ${workVpnPass}/bin/workVpnPass ]

  spawn ${spawnCommand}
  expect {
    "Username:*" {
      sleep 1
      send "$username\r"
      exp_continue
    }
    "Password:" {
      sleep 1
      send "$password\r"
      exp_continue
    }
    "${otpRequest}" {
      sleep 1
      send "4\r"
      expect {
        "${otpRequest}" {
          sleep 1
          set otp [ exec ${workVpnOtp}/bin/workVpnOtp ]
          send "$otp\r"
          exp_continue
        }
      }
      exp_continue
    }
  }
''
