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
    ../olimpik/MS-7B85.nix
  ];

  my = {
    host = "MS-7B85";
    wifi-interface = "wlo1";
  };

  boot = {
    kernelModules = [
      "amdgpu"
      "radeon"
    ];
    kernelParams = [
      "video=DP-1:2560x1080@75e"
      "video=HDMI-A-1:1680x1050@60e"

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
    hostName = "PC-MAIN";
    firewall = {
      enable = false;
    };
    networkmanager = {
      enable = true;
    };
  };

  fileSystems = {
    "/mnt/SATA-SSD-Samsung-2TB-1" = {
      device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_2TB_S750NX0XA02176T-part1";
      fsType = "ntfs";
      options = [
        "rw"
        "uid=1000"
        "gid=100"
        "nofail"
      ];
    };
    "/mnt/NVME-WesternDigital-500GB-1" = {
      device = "/dev/disk/by-id/nvme-WDC_WDS500G2B0C-00PXH0_2025C5474406-part3";
      fsType = "ntfs";
      options = [
        "rw"
        "uid=1000"
        "gid=100"
        "nofail"
      ];
    };
  };

  services = {
    nix-serve = {
      enable = true;
      secretKeyFile = config.sops.secrets."nix/cache".path;
    };
    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "server string" = "pc-main";
          "netbios name" = "pc-main";
          "security" = "user";
          "hosts allow" = "192.168.88. 127.0.0.1 localhost";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        movies = {
          "path" = "/mnt/SATA-SSD-Samsung-2TB-1/torrents/movies";
          "browseable" = "yes";
          "read only" = "yes";
          "guest ok" = "yes";
        };
      };
    };
    minidlna = {
      enable = true;
      openFirewall = true;

      settings = {
        friendly_name = "pc-main";
        media_dir = [
          "V,/mnt/SATA-SSD-Samsung-2TB-1/torrents/movies"
        ];

        db_dir = "/var/cache/minidlna";
        log_dir = "/var/log/minidlna";

        inotify = "yes";
        enable_tivo = "no";
        strict_dlna = "no";
      };
    };
  };
}
