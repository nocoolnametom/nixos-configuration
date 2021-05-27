# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# Remember to symlink this into the expected location!
# `sudo ln -s <absolute path to this file> /etc/nixos/configuration.nix

{ config, pkgs, lib ? pkgs.lib, ... }:

let
  workInfo = if pkgs.lib.pathExists ./workInfo.nix then
    (import ./workInfo.nix { inherit pkgs lib; })
  else
    (import ./workInfo_example.nix { inherit pkgs lib; });
in {
  imports = [
    # Include the results of the hardware scan. Absolute so we can symlink the main congfiguration file to `/etc/nixos`
    /etc/nixos/hardware-configuration.nix
    (import "${
        builtins.fetchTarball
        "https://github.com/rycee/home-manager/archive/master.tar.gz"
      }/nixos")
    ./overlays-import.nix
    ./myConfigurations
  ] ++ (lib.optionals (lib.pathExists ./configuration.nix)
    [ ./configuration.nix ]);

  boot.kernelParams = [ "apparmor=1" "security=apparmor" ];

  # Allow file watchers (like in VSCode) to watch more files
  # boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  networking.networkmanager.enable = true; # Use NMCLI for Wifi/VPN access
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens33.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # NetworkManager connections
  environment.etc."NetworkManager/system-connections/Zillow-VPN.nmconnection" =
    {
      enable = true;
      mode = "0600";
      text = ''
        [connection]
        id=Zillow VPN
        uuid=1047082f-2851-4225-b1e0-9d556477b88f
        type=vpn
        autoconnect=false
        permissions=
        timestamp=1596818105

        [vpn]
        authtype=password
        autoconnect-flags=0
        certsigs-flags=0
        cookie-flags=2
        enable_csd_trojan=no
        gateway=sfo.vpn.zillowgroup.com
        gateway-flags=2
        gwcert-flags=2
        lasthost-flags=0
        pem_passphrase_fsid=no
        prevent_invalid_cert=no
        protocol=anyconnect
        stoken_source=disabled
        xmlconfig-flags=0
        service-type=org.freedesktop.NetworkManager.openconnect
        user-name=tdoggett

        [vpn-secrets]
        autoconnect=yes
        form:main:group_list=zillow
        form:main:username=tdoggett
        lasthost=ZillowGroup San Francisco
        save_passwords=yes
        xmlconfig=PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4NCjxBbnlDb25uZWN0UHJvZmlsZSB4bWxucz0iaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvZW5jb2RpbmcvIiB4bWxuczp4c2k9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvWE1MU2NoZW1hLWluc3RhbmNlIiB4c2k6c2NoZW1hTG9jYXRpb249Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL2VuY29kaW5nLyBBbnlDb25uZWN0UHJvZmlsZS54c2QiPg0KCTxDbGllbnRJbml0aWFsaXphdGlvbj4NCgkJPFVzZVN0YXJ0QmVmb3JlTG9nb24gVXNlckNvbnRyb2xsYWJsZT0idHJ1ZSI+ZmFsc2U8L1VzZVN0YXJ0QmVmb3JlTG9nb24+DQoJCTxBdXRvbWF0aWNDZXJ0U2VsZWN0aW9uIFVzZXJDb250cm9sbGFibGU9InRydWUiPmZhbHNlPC9BdXRvbWF0aWNDZXJ0U2VsZWN0aW9uPg0KCQk8U2hvd1ByZUNvbm5lY3RNZXNzYWdlPmZhbHNlPC9TaG93UHJlQ29ubmVjdE1lc3NhZ2U+DQoJCTxDZXJ0aWZpY2F0ZVN0b3JlPkFsbDwvQ2VydGlmaWNhdGVTdG9yZT4NCgkJPENlcnRpZmljYXRlU3RvcmVNYWM+QWxsPC9DZXJ0aWZpY2F0ZVN0b3JlTWFjPg0KCQk8Q2VydGlmaWNhdGVTdG9yZU92ZXJyaWRlPmZhbHNlPC9DZXJ0aWZpY2F0ZVN0b3JlT3ZlcnJpZGU+DQoJCTxQcm94eVNldHRpbmdzPk5hdGl2ZTwvUHJveHlTZXR0aW5ncz4NCgkJPEFsbG93TG9jYWxQcm94eUNvbm5lY3Rpb25zPnRydWU8L0FsbG93TG9jYWxQcm94eUNvbm5lY3Rpb25zPg0KCQk8QXV0aGVudGljYXRpb25UaW1lb3V0PjEyPC9BdXRoZW50aWNhdGlvblRpbWVvdXQ+DQoJCTxBdXRvQ29ubmVjdE9uU3RhcnQgVXNlckNvbnRyb2xsYWJsZT0iZmFsc2UiPmZhbHNlPC9BdXRvQ29ubmVjdE9uU3RhcnQ+DQoJCTxNaW5pbWl6ZU9uQ29ubmVjdCBVc2VyQ29udHJvbGxhYmxlPSJ0cnVlIj50cnVlPC9NaW5pbWl6ZU9uQ29ubmVjdD4NCgkJPExvY2FsTGFuQWNjZXNzIFVzZXJDb250cm9sbGFibGU9ImZhbHNlIj50cnVlPC9Mb2NhbExhbkFjY2Vzcz4NCgkJPERpc2FibGVDYXB0aXZlUG9ydGFsRGV0ZWN0aW9uIFVzZXJDb250cm9sbGFibGU9ImZhbHNlIj5mYWxzZTwvRGlzYWJsZUNhcHRpdmVQb3J0YWxEZXRlY3Rpb24+DQoJCTxDbGVhclNtYXJ0Y2FyZFBpbiBVc2VyQ29udHJvbGxhYmxlPSJmYWxzZSI+ZmFsc2U8L0NsZWFyU21hcnRjYXJkUGluPg0KCQk8SVBQcm90b2NvbFN1cHBvcnQ+SVB2NCxJUHY2PC9JUFByb3RvY29sU3VwcG9ydD4NCgkJPEF1dG9SZWNvbm5lY3QgVXNlckNvbnRyb2xsYWJsZT0idHJ1ZSI+dHJ1ZQ0KCQkJPEF1dG9SZWNvbm5lY3RCZWhhdmlvciBVc2VyQ29udHJvbGxhYmxlPSJ0cnVlIj5SZWNvbm5lY3RBZnRlclJlc3VtZTwvQXV0b1JlY29ubmVjdEJlaGF2aW9yPg0KCQk8L0F1dG9SZWNvbm5lY3Q+DQoJCTxTdXNwZW5kT25Db25uZWN0ZWRTdGFuZGJ5PmZhbHNlPC9TdXNwZW5kT25Db25uZWN0ZWRTdGFuZGJ5Pg0KCQk8QXV0b1VwZGF0ZSBVc2VyQ29udHJvbGxhYmxlPSJmYWxzZSI+dHJ1ZTwvQXV0b1VwZGF0ZT4NCgkJPFJTQVNlY3VySURJbnRlZ3JhdGlvbiBVc2VyQ29udHJvbGxhYmxlPSJmYWxzZSI+QXV0b21hdGljPC9SU0FTZWN1cklESW50ZWdyYXRpb24+DQoJCTxXaW5kb3dzTG9nb25FbmZvcmNlbWVudD5TaW5nbGVMb2NhbExvZ29uPC9XaW5kb3dzTG9nb25FbmZvcmNlbWVudD4NCgkJPExpbnV4TG9nb25FbmZvcmNlbWVudD5TaW5nbGVMb2NhbExvZ29uPC9MaW51eExvZ29uRW5mb3JjZW1lbnQ+DQoJCTxXaW5kb3dzVlBORXN0YWJsaXNobWVudD5Mb2NhbFVzZXJzT25seTwvV2luZG93c1ZQTkVzdGFibGlzaG1lbnQ+DQoJCTxMaW51eFZQTkVzdGFibGlzaG1lbnQ+TG9jYWxVc2Vyc09ubHk8L0xpbnV4VlBORXN0YWJsaXNobWVudD4NCgkJPEF1dG9tYXRpY1ZQTlBvbGljeT5mYWxzZTwvQXV0b21hdGljVlBOUG9saWN5Pg0KCQk8UFBQRXhjbHVzaW9uIFVzZXJDb250cm9sbGFibGU9ImZhbHNlIj5EaXNhYmxlDQoJCQk8UFBQRXhjbHVzaW9uU2VydmVySVAgVXNlckNvbnRyb2xsYWJsZT0iZmFsc2UiPjwvUFBQRXhjbHVzaW9uU2VydmVySVA+DQoJCTwvUFBQRXhjbHVzaW9uPg0KCQk8RW5hYmxlU2NyaXB0aW5nIFVzZXJDb250cm9sbGFibGU9ImZhbHNlIj5mYWxzZTwvRW5hYmxlU2NyaXB0aW5nPg0KCQk8RW5hYmxlQXV0b21hdGljU2VydmVyU2VsZWN0aW9uIFVzZXJDb250cm9sbGFibGU9InRydWUiPmZhbHNlDQoJCQk8QXV0b1NlcnZlclNlbGVjdGlvbkltcHJvdmVtZW50PjIwPC9BdXRvU2VydmVyU2VsZWN0aW9uSW1wcm92ZW1lbnQ+DQoJCQk8QXV0b1NlcnZlclNlbGVjdGlvblN1c3BlbmRUaW1lPjQ8L0F1dG9TZXJ2ZXJTZWxlY3Rpb25TdXNwZW5kVGltZT4NCgkJPC9FbmFibGVBdXRvbWF0aWNTZXJ2ZXJTZWxlY3Rpb24+DQoJCTxSZXRhaW5WcG5PbkxvZ29mZj5mYWxzZQ0KCQk8L1JldGFpblZwbk9uTG9nb2ZmPg0KCQk8Q2FwdGl2ZVBvcnRhbFJlbWVkaWF0aW9uQnJvd3NlckZhaWxvdmVyPmZhbHNlPC9DYXB0aXZlUG9ydGFsUmVtZWRpYXRpb25Ccm93c2VyRmFpbG92ZXI+DQoJCTxBbGxvd01hbnVhbEhvc3RJbnB1dD50cnVlPC9BbGxvd01hbnVhbEhvc3RJbnB1dD4NCgk8L0NsaWVudEluaXRpYWxpemF0aW9uPg0KCTxTZXJ2ZXJMaXN0Pg0KCQk8SG9zdEVudHJ5Pg0KCQkJPEhvc3ROYW1lPlppbGxvd0dyb3VwIERlbnZlcjwvSG9zdE5hbWU+DQoJCQk8SG9zdEFkZHJlc3M+ZGVuLnZwbi56aWxsb3dncm91cC5jb208L0hvc3RBZGRyZXNzPg0KCQk8L0hvc3RFbnRyeT4NCgkJPEhvc3RFbnRyeT4NCgkJCTxIb3N0TmFtZT5aaWxsb3dHcm91cCBTZWF0dGxlPC9Ib3N0TmFtZT4NCgkJCTxIb3N0QWRkcmVzcz5zZWEudnBuLnppbGxvd2dyb3VwLmNvbTwvSG9zdEFkZHJlc3M+DQoJCTwvSG9zdEVudHJ5Pg0KCQk8SG9zdEVudHJ5Pg0KCQkJPEhvc3ROYW1lPlppbGxvd0dyb3VwIElydmluZTwvSG9zdE5hbWU+DQoJCQk8SG9zdEFkZHJlc3M+aXJ2LnZwbi56aWxsb3dncm91cC5jb208L0hvc3RBZGRyZXNzPg0KCQk8L0hvc3RFbnRyeT4NCgkJPEhvc3RFbnRyeT4NCgkJCTxIb3N0TmFtZT5aaWxsb3dHcm91cCBDaW5jaW5uYXRpPC9Ib3N0TmFtZT4NCgkJCTxIb3N0QWRkcmVzcz5jaW4udnBuLnppbGxvd2dyb3VwLmNvbTwvSG9zdEFkZHJlc3M+DQoJCTwvSG9zdEVudHJ5Pg0KCQk8SG9zdEVudHJ5Pg0KCQkJPEhvc3ROYW1lPlppbGxvd0dyb3VwIExpbmNvbG48L0hvc3ROYW1lPg0KCQkJPEhvc3RBZGRyZXNzPmxuay52cG4uemlsbG93Z3JvdXAuY29tPC9Ib3N0QWRkcmVzcz4NCgkJPC9Ib3N0RW50cnk+DQoJCTxIb3N0RW50cnk+DQoJCQk8SG9zdE5hbWU+WmlsbG93R3JvdXAgTmV3IFlvcms8L0hvc3ROYW1lPg0KCQkJPEhvc3RBZGRyZXNzPm55Yy52cG4uemlsbG93Z3JvdXAuY29tPC9Ib3N0QWRkcmVzcz4NCgkJPC9Ib3N0RW50cnk+DQoJCTxIb3N0RW50cnk+DQoJCQk8SG9zdE5hbWU+WmlsbG93R3JvdXAgU2FuIEZyYW5jaXNjbzwvSG9zdE5hbWU+DQoJCQk8SG9zdEFkZHJlc3M+c2ZvLnZwbi56aWxsb3dncm91cC5jb208L0hvc3RBZGRyZXNzPg0KCQk8L0hvc3RFbnRyeT4NCgk8L1NlcnZlckxpc3Q+DQo8L0FueUNvbm5lY3RQcm9maWxlPg0K

        [ipv4]
        dns-search=
        method=auto

        [ipv6]
        addr-gen-mode=stable-privacy
        dns-search=
        ip6-privacy=0
        method=auto

        [proxy]
      '';
    };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.variables = {
    EDITOR = "vim";
    HOME = "/home/tdoggett";
    PAGER = "less -R";
  };
  environment.shellAliases = {
    hm = "home-manager";
    rm = "rm -i";
    cp = "cp -i";
    ls = "ls -G";
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Security
  security.sudo.wheelNeedsPassword = false;
  security.apparmor.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnumake
    wget
    vim
    zsh
    nixfmt
    awscli
    curl
    direnv
    silver-searcher
    nodejs-14_x
  ];

  # programs.mtr.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix.autoOptimiseStore = true;

  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 30d";

  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";

  programs.bash.enableCompletion = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.zsh.enable = true;

  # List services that you want to enable:	

  # MySQL
  services.mysql.enable = true;
  services.mysql.package = pkgs.mysql;

  # Enable the NTP daemon.
  services.ntp.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable building LXD containers
  virtualisation.lxd.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # Write current configuration files to a derivation that can be read.
  # This is helpful if you are loading a previous generation that is not
  # in sync with the current values in /etc/nixos/configuration.nix
  # The output can be found at /run/current-system/configuration.nix
  system.copySystemConfiguration = true;
  system.extraSystemBuilderCmds = "ln -s ${./.} $out/full-config";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlKRzkkOsGyYRGYx65QhYFPNtm2KM5ghlVX8rUkWwh47fIeAmdVRRgcXpDuITxO9BSe5jDhxyhGa6rLfkNLsHHgV5F0nT5XNIRZyf1UcSgIhZmBI0uX471Q6VFXsZisTlKKO/wkJljf4Ov7euqyAAyzUG2UjZcbMxu0Ggp8A2mazog14ux2Jr1al2CYPzunhZwMmnabRsIaHLXN4VIBfDIDMqO4zKKpED314G3yCzdIn8V4dAEiTx6ZXowvG3WisqVrQiXb0hjqEqsDF2eJyAsnx4X2UUIG//07ZPte5wma/cFniiHFF4UTN9JQdBiw3XigLxl/sbHbi20Xty+qXaF nocoolnametom@gmail.com"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHRGHHW723oTlQDBZ9HTvzwUOv7jYuOzb4o4m9H69eJJojtZn6GhBzaCexYwAEOrQjXipxh6gbht+On5i1RqNmoOKvHWBVhsrffafIQ1iCpzmRSmyNnSD5LND+Uf0DCwaJrLv4IbR+U69ovO9TCcz/VovIZfRN027MD1mP94DzwpG2b5NfRfM6YBXQKfifOZ+LOzuLVOGhpaN7At2Mj6qomFHYtDuF51SrzHh0boMLEtEtH4ZXhe68f94IchUUgVgU7776nXDPDXNdcS6MYa58lc5JHVWRAhNk8upQQrfg2pXYI7qfHGbnSIj+lRSDCbQ05GYsdrgkV1OKjGFkaHTl Work Public Key"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6+C6YhL8ryo0hEJv15oXC2kbyQQfFXfNBlDmcy3/UO+RQ82HFsvIPlPCCR3HtkVA/eecVV2qpwBqRXW073Ku/kqOVvuTRxei+5mfmYYEEwr62iU9wY8+DGhelozmafcv95Cg0AWaVYxyTmOgEY80/ZM9dMQ3NBgVP7ahFTKQ1VifexaLfK1OJXvrC1SWMsn96FETir6tiEpdDQUGMm8I8rXOrMJi+7Erty15dcmOs5YysyBEbYkD10XNvl5ZpeE1Qq+M6EZuALAU7nG1qGEaWxrgo7wFCZ2u7VBHK/fAVH4Hg/cU2dLbbvLab8gT5i1uiGyxpPf6M3FJOCTh6QL6d1i3QbTgD8rZIYjqQfgFAHXhdX9qTLokjphe6LyYB81dPFtdWYjVsrSF3CEJRWg6LdQ721zoajyE2rfAlL8pomLEUtM29pnPR16Uss3mfPuxUNABh+rC1bPXYx3gtsx8xF1/EqdmyDxdfsgl5xjrMZGATatMufIo8ANu17sVZmEs= tom@nocoolnametom.com"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzIOpbdJpXxndFaSKVgIJwQDbNdDQSXblrlRvVJdqFB5FSH8zOSVqfAgBt/r1skOuMSL7mrEJxldOfLu6QCIqnjv/5pk09EojWKdtCnFn/O6QiTxL98GktEZc1uykeW3TBBU5F3K6IJXz9r+yDGsGnJE90LP6f5r9DMwGpYuuU7aS8fbUcQJU9E7lWfQQOoR+GpKz75uJSuTEGfdXjsJh/CCPZQ/jHZeeQYtLUS6E4MfVMwhxovZAKCTXUE2O9LtwIB2nZIR4+L1ZF6wjQDh73FTBuy5kodE10dXqbWnRT2gcSk0txUHBJVNT/0aOYOkE8psRr+5iQqOOKscysCvbP8NtUtI3BhfsO5WpZCNm5VVmrDoCQ5c3emTgrwZJhBZkgUjJluHdFVca6N4lD+tSEY14FlH8NNYy02n2TzzRNl9RVIVAWJ7r0DDGf8ykP0X/bOW5SerZSYKQJ8jtenX5ZqjnOenWf7OGbY90NIf4YpmK3Qs1xiAEd5/i5M5MABiM= tdoggett@zillowgroup.com"
  ];
  # users.users.root.initialHashedPassword = "Set this in the local configuration.nix file!";

  users.extraGroups.tdoggett.gid = 499;
  users.extraUsers.tdoggett.isNormalUser = true;
  users.extraUsers.tdoggett.description = "Tom Doggett";
  users.extraUsers.tdoggett.group = "tdoggett";
  users.extraUsers.tdoggett.packages = [ pkgs.git ];
  users.extraUsers.tdoggett.extraGroups = [
    "adbusers"
    "wheel"
    "networkmanager"
    "users"
    "audio"
    "video"
    "lxd"
    "docker"
    "dialout"
  ];
  # users.extraUsers.tdoggett.hashedPassword = "Set this in the local configuration.nix file!";
  users.extraUsers.tdoggett.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlKRzkkOsGyYRGYx65QhYFPNtm2KM5ghlVX8rUkWwh47fIeAmdVRRgcXpDuITxO9BSe5jDhxyhGa6rLfkNLsHHgV5F0nT5XNIRZyf1UcSgIhZmBI0uX471Q6VFXsZisTlKKO/wkJljf4Ov7euqyAAyzUG2UjZcbMxu0Ggp8A2mazog14ux2Jr1al2CYPzunhZwMmnabRsIaHLXN4VIBfDIDMqO4zKKpED314G3yCzdIn8V4dAEiTx6ZXowvG3WisqVrQiXb0hjqEqsDF2eJyAsnx4X2UUIG//07ZPte5wma/cFniiHFF4UTN9JQdBiw3XigLxl/sbHbi20Xty+qXaF nocoolnametom@gmail.com"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHRGHHW723oTlQDBZ9HTvzwUOv7jYuOzb4o4m9H69eJJojtZn6GhBzaCexYwAEOrQjXipxh6gbht+On5i1RqNmoOKvHWBVhsrffafIQ1iCpzmRSmyNnSD5LND+Uf0DCwaJrLv4IbR+U69ovO9TCcz/VovIZfRN027MD1mP94DzwpG2b5NfRfM6YBXQKfifOZ+LOzuLVOGhpaN7At2Mj6qomFHYtDuF51SrzHh0boMLEtEtH4ZXhe68f94IchUUgVgU7776nXDPDXNdcS6MYa58lc5JHVWRAhNk8upQQrfg2pXYI7qfHGbnSIj+lRSDCbQ05GYsdrgkV1OKjGFkaHTl Work Public Key"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6+C6YhL8ryo0hEJv15oXC2kbyQQfFXfNBlDmcy3/UO+RQ82HFsvIPlPCCR3HtkVA/eecVV2qpwBqRXW073Ku/kqOVvuTRxei+5mfmYYEEwr62iU9wY8+DGhelozmafcv95Cg0AWaVYxyTmOgEY80/ZM9dMQ3NBgVP7ahFTKQ1VifexaLfK1OJXvrC1SWMsn96FETir6tiEpdDQUGMm8I8rXOrMJi+7Erty15dcmOs5YysyBEbYkD10XNvl5ZpeE1Qq+M6EZuALAU7nG1qGEaWxrgo7wFCZ2u7VBHK/fAVH4Hg/cU2dLbbvLab8gT5i1uiGyxpPf6M3FJOCTh6QL6d1i3QbTgD8rZIYjqQfgFAHXhdX9qTLokjphe6LyYB81dPFtdWYjVsrSF3CEJRWg6LdQ721zoajyE2rfAlL8pomLEUtM29pnPR16Uss3mfPuxUNABh+rC1bPXYx3gtsx8xF1/EqdmyDxdfsgl5xjrMZGATatMufIo8ANu17sVZmEs= tom@nocoolnametom.com"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzIOpbdJpXxndFaSKVgIJwQDbNdDQSXblrlRvVJdqFB5FSH8zOSVqfAgBt/r1skOuMSL7mrEJxldOfLu6QCIqnjv/5pk09EojWKdtCnFn/O6QiTxL98GktEZc1uykeW3TBBU5F3K6IJXz9r+yDGsGnJE90LP6f5r9DMwGpYuuU7aS8fbUcQJU9E7lWfQQOoR+GpKz75uJSuTEGfdXjsJh/CCPZQ/jHZeeQYtLUS6E4MfVMwhxovZAKCTXUE2O9LtwIB2nZIR4+L1ZF6wjQDh73FTBuy5kodE10dXqbWnRT2gcSk0txUHBJVNT/0aOYOkE8psRr+5iQqOOKscysCvbP8NtUtI3BhfsO5WpZCNm5VVmrDoCQ5c3emTgrwZJhBZkgUjJluHdFVca6N4lD+tSEY14FlH8NNYy02n2TzzRNl9RVIVAWJ7r0DDGf8ykP0X/bOW5SerZSYKQJ8jtenX5ZqjnOenWf7OGbY90NIf4YpmK3Qs1xiAEd5/i5M5MABiM= tdoggett@zillowgroup.com"
  ];

  # Home Manager
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.tdoggett = import ./home.dist.nix {
    inherit pkgs config;
    isModule = true;
    isDarwin = false;
  };
}

