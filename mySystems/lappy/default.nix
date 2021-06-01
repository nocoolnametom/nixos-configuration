{ pkgs, config, lib, ... }: {

  # Work Root Password
  users.users.root.initialHashedPassword =
    "$6$Xjjhywyd625$H9Wk8CI5ayxeEtzt5iyigRDdgwPrkbWBQSCoCayGoxgji0AxgrOJHhzgRDAhH51JkSwqjbsTWlLn4L9rLKk/W1";

  # Work User Password
  users.extraUsers.tdoggett.hashedPassword =
    "$6$7ZBLMVyR$JzrOk7tD4AaxvibjqxqX3zY94e6UYKIOwDjxj1mvIFsju9w/6anNO9AZZjdRDGMepCtorpUOn7HsnK6vQGjws/";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
    "psmouse.synaptics_intertouch=1"
    "apparmor=1"
    "security=apparmor"
    # https://bugzilla.kernel.org/show_bug.cgi?id=110941
    "intel_pstate=no_hwp"
    "nvidia-drm.modeset=1"
  ];

  # Allow file watchers (like in VSCode) to watch more files
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Supposedly better for the SSD
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/1563269d-b028-4923-be8c-b91187dba3ae";
      preLVM = true;
      allowDiscards = true;
    };
  };

  # Thinkpad fan control
  services.thinkfan.enable = true;
  services.thinkfan.levels = [
    [ 0 0 65 ]
    [ 1 50 70 ]
    [ 2 60 71 ]
    [ 3 62 73 ]
    [ 6 66 75 ]
    [ 7 70 85 ]
    [ 127 80 32767 ]
  ];

  # Scale down CPU when not using it to conserve battery life
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "ondemand";

  # Strong Laptop Power Autoconfiguration
  services.tlp.enable = true;

  # Enable changing BlinkStick color and brightness
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="20a0", ATTR{idProduct}=="41e5", MODE:="0666"
  '';

  # Replace regular virtual consoles with KMS for font control
  services.kmscon.enable = false;
  services.kmscon.extraConfig = ''
    font-name=Cascadia Code
  '';

  # Fonts
  fonts.fontDir.enable = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    dejavu_fonts
    fira-code
    liberation_ttf
    ubuntu_font_family
  ];
  fonts.fontconfig = {
    dpi = 142;
    hinting.autohint = false;
    useEmbeddedBitmaps = true;
    defaultFonts.serif = [ "Liberation Serif" "Times New Roman" ];
    defaultFonts.sansSerif = [ "Liberation Serif" "Ubuntu" ];
    defaultFonts.monospace = [ "DejaVu Sans Mono" "Fira Code" "Ubuntu Mono" ];
  };

  # Helper program to control display brightness, etc
  programs.light.enable = true;
  programs.adb.enable = true;

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      swaybg
      swaylock-effects
      swayidle
      xwayland
      waybar
      bemenu
      j4-dmenu-desktop
      mako
      kanshi
      libappindicator
    ];
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];
  xdg.portal.gtkUsePortal = true;

  services.pipewire.enable = true;

  services.xserver.dpi = 142;
  services.xserver.xrandrHeads = [
    {
      output = "eDP-1";
      primary = true;
      monitorConfig = ''
        Option "PreferredMode" "1920x1080"
        Option "Position" "0 440"
        Option "Rotate" "Normal"
      '';
    }
    {
      output = "DP-0";
      primary = false;
      monitorConfig = ''
        Option "PreferredMode" "2560x1440"
        Option "Position" "1920 0"
        Option "Rotate" "Left"
        Option "Scale" "1.25x1.25"
      '';
    }
  ];
  hardware.enableAllFirmware = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.prime = {
    offload.enable = true;
    sync.enable = true;
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };

  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];

  virtualisation.lxd.enable =
    false; # Something here is preventing builds when apparmor is enabled..

  networking.firewall.allowedTCPPorts = [ 5900 ];

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [
    # pkgs.hplipWithPlugin
    pkgs.gutenprint
    pkgs.gutenprintBin
  ];
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  # Enadle SANE to scan documents.
  hardware.sane.enable = true;

  # Enable sound.
  sound.enable = true;
  sound.mediaKeys.enable = true;
  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.support32Bit = true;
  hardware.pulseaudio.extraConfig = ''
    ### Enable Echo/Noise-Cancellation
    load-module module-echo-cancel use_master_format=1 aec_method=webrtc aec_args="analog_gain_control=0\ digital_gain_control=1 extended_filter=1 beamforming=1 mic_geometry=-0.0257,0,0,0.0257,0,0" source_name=echoCancel_source sink_name=echoCancel_sink
    set-default-source echoCancel_source
    set-default-sink echoCancel_sink
  '';

  # Power Management
  services.upower.enable = true;

  # Thunerbolt Management
  services.hardware.bolt.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = false;
  services.xserver.layout = "us";
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.displayManager.lightdm.enable = false;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "tdoggett";
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.defaultSession = "none+i3";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  services.dbus.packages = with pkgs; [ blueman gnome3.dconf ];
  services.blueman.enable = true;

  # Environmental Variables for all users
  environment.variables._JAVA_AWT_WM_NONREPARENTING = "1";
  environment.variables.MOZ_ENABLE_WAYLAND = "1";
  environment.variables.MOZ_DBUS_REMOTE = "1";
  environment.variables.QT_QPA_PLATFORM = "wayland";
  environment.variables.QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  environment.variables.XCURSOR_SIZE = "36";
  environment.variables.BEMENU_BACKEND = "wayland";
  environment.variables.XDG_CURRENT_DESKTOP = "sway";
  environment.variables.XDG_SESSION_TYPE = "wayland";
}
