{ pkgs, config, lib, ... }: {

  # Work Root Password
  users.users.root.initialHashedPassword =
    "$6$Xjjhywyd625$H9Wk8CI5ayxeEtzt5iyigRDdgwPrkbWBQSCoCayGoxgji0AxgrOJHhzgRDAhH51JkSwqjbsTWlLn4L9rLKk/W1";

  # Work User Password
  users.extraUsers.tdoggett.hashedPassword =
    "$6$98ptkUGOd64$/Fe55LD1T4XEpW43UJTxzcMcCd.hVTNIFcj7EZheHVeHzR7cliepQVENeq7XUS4vqSoA78Cu2HOQ8HVswAgVR.";

  virtualisation.vmware.guest.enable = true;
  virtualisation.vmware.guest.headless = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
}
