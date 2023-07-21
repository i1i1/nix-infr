{ name, ... }:
{
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
    };

  swapDevices = [ ];

  networking.useDHCP = true;
  virtualisation.hypervGuest.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = name; # Define your hostname.

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "nixos" "i1i1" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  time.timeZone = "Europe/Moscow";

  users.mutableUsers = false;
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIeDmFIaYeY72jWpxtHMqJXSR7etJaWN/X5bl9rBKRW1 i1i1@i1i1"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9fbpPiyH7awWQnBXFhWFCEO1E0Azs6HQeCbZTDTBSg i1i1@i1i1"
    ];
  };

  environment.defaultPackages = [ ];
  environment.systemPackages = [ ];
  environment.noXlibs = true;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "no";

  system.stateVersion = "23.05";
}
