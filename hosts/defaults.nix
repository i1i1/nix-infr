{ pkgs, name, ... }:
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
    hashedPassword = "$6$hmYNQ2jo5Z70p2Am$tvp6rq2lly1iaMgAQgOq03ZWyA29ZKwKrUOUNZvuEDqg1ot2AUCS762JPpzEWfVLnGSaBgIiaFqxnSwS4fkGv1";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIeDmFIaYeY72jWpxtHMqJXSR7etJaWN/X5bl9rBKRW1 i1i1@i1i1"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";

  system.stateVersion = "23.05";
}