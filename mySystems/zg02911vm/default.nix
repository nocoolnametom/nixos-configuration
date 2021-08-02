{ pkgs, config, lib, ... }: {

  # Work Root Password
  users.users.root.initialHashedPassword =
    "$6$Xjjhywyd625$H9Wk8CI5ayxeEtzt5iyigRDdgwPrkbWBQSCoCayGoxgji0AxgrOJHhzgRDAhH51JkSwqjbsTWlLn4L9rLKk/W1";

  # Work User Password
  users.extraUsers.tdoggett.hashedPassword =
    "$6$98ptkUGOd64$/Fe55LD1T4XEpW43UJTxzcMcCd.hVTNIFcj7EZheHVeHzR7cliepQVENeq7XUS4vqSoA78Cu2HOQ8HVswAgVR.";

  virtualisation.vmware.guest.enable = true;
  virtualisation.vmware.guest.headless = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  virtualisation.lxd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;

  # Use DHCP for wireless network connection
  networking.interfaces.ens33.useDHCP = true;

  fileSystems."/host" = {
    device = ".host:/";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options = [
      "umask=22"
      "uid=1000"
      "gid=499"
      "allow_other"
      "defaults"
      "auto_unmount"
    ];
  };
}
