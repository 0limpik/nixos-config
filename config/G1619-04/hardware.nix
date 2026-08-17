{
  config,
  lib,
  pkbs,
  modulesPath,
  ...
}:
{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "sdhci_pci"
      ];
      kernelModules = [ ];
    };
    kernelModules = [
      "kvm-amd"
    ];
    extraModulePackages = [ ];
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
  };

  hardware = {
    cpu = {
      amd = {
        updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
  };
}