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
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-bd53cc83-0b93-4b77-be5e-fb3287a8a871".device = "/dev/disk/by-uuid/bd53cc83-0b93-4b77-be5e-fb3287a8a871";
  boot.initrd.luks.devices."luks-bd53cc83-0b93-4b77-be5e-fb3287a8a871".keyFile = "/crypto_keyfile.bin";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.xterm.enable = false;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable the fingerprint scanner
  services.fprintd.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
}
