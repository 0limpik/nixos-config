{
  config,
  lib,

  inputs,
  pkgs-s,
  pkgs-u,
  ...
}:
{
  imports = [
    ./hardware.nix
    "${inputs.disko}/module.nix"
    ./disko.nix

    ../.
    ../olimpik/.
    ../olimpik/G1619-04.nix
  ];

  my = {
    host = "G1619-04";
    wifi-interface = "wlp1s0";
  };

  boot = {
    kernelModules = [
      "amdgpu"
      "radeon"
    ];
    kernelParams = [
      "amdgpu.ppfeaturemask=0xffffffff"
    ];
  };

  hardware = {
    graphics = {
      enable = true;
      package = pkgs-u.mesa;
      extraPackages = with pkgs-u; [
        rocmPackages.clr.icd
        rocmPackages.clr
        amf
      ];
    };
    steam-hardware.enable = true;
    amdgpu.overdrive = {
      enable = true;
      ppfeaturemask = "0xffffffff";
    };
  };

  networking = {
    hostName = "PC-MINI";
    firewall = {
      enable = false;
    };
    networkmanager = {
      enable = true;
    };
  };

  environment.systemPackages = [
    pkgs-s.brightnessctl
  ];
  services.udev.packages = [
    pkgs-s.brightnessctl
  ];
}
