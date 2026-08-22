{
  config,
  lib,
  lib-o,

  inputs,
  pkgs-s,
  pkgs-u,
  ...
}:
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "dynamic-derivations"
        "ca-derivations"
        "recursive-nix"
        # "impure-derivations"
      ];
      substituters = [
        "http://pc-main.lan:5000"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "pc-main.lan:ycaAvr7Zp1pnTIBheEHWg7sNaFBGe03AVqt6pke8Qos="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      trusted-users = [
        "olimpik"
      ];
      connect-timeout = 2;
      download-attempts = 3;
      warn-dirty = false;
    };
    channel.enable = false;
    registry = with inputs; {
      s.to = {
        type = "path";
        path = nixpkgs-s.outPath;
      };
      u.to = {
        type = "path";
        path = nixpkgs-u.outPath;
      };
      m.to = {
        type = "path";
        path = nixpkgs-m.outPath;
      };
      o.to = {
        type = "path";
        path = olimpikpkgs.outPath;
      };
    };
    nixPath = with inputs; [
      "nixpkgs=${nixpkgs-u.outPath}"

      "nixpkgs-s=${nixpkgs-s.outPath}"
      "nixpkgs-u=${nixpkgs-u.outPath}"
      "nixpkgs-m=${nixpkgs-m.outPath}"

      "olimpikpkgs=${olimpikpkgs.outPath}"
    ];
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "kernel.sysrq" = 502;
      "kernel.yama.ptrace_scope" = 0;
    };
    kernelPackages = pkgs-s.linuxPackages_6_18;
    supportedFilesystems = [
      "ntfs"
    ];
  };

  time.timeZone = "Europe/Moscow";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = [
      "ru_RU.UTF-8/UTF8"
    ];
  };

  users.users.olimpik = {
    description = "Owner";
    isNormalUser = true;
    extraGroups = [
      "sudo"
      "wheel"
      "network"
      "audio"
      "video"
      "input"
      "networkmanager"
      "seat"
      "tty"
    ];
    openssh = {
      authorizedKeys = {
        keyFiles = [
          "${lib-o.user "olimpik"}/ssh.pub"
        ];
      };
    };
  };

  security.sudo.extraConfig = ''
    Defaults:olimpik timestamp_timeout=45
  '';

  networking = {
    networkmanager = {
      enable = true;
      ensureProfiles = {
        environmentFiles = [
          config.sops.secrets."networking/ax3_2".path
          config.sops.secrets."networking/ax3_5".path
          config.sops.secrets."networking/ax1500_5".path
        ];
        profiles =
          let
            # print: nmcli --fields SSID,BSSID,FREQ device wifi list
            # location: /run/NetworkManager/system-connections/
            # fields: https://networkmanager.pages.freedesktop.org/NetworkManager/NetworkManager/nm-settings-nmcli.html
            mkProfile = name: {
              connection = {
                id = "\$${name}__ID";
                uuid = "\$${name}__UUID";
                type = "wifi";
                interface-name = config.my.wifi-interface;
                autoconnect-priority = lib.toInt (builtins.elemAt (builtins.match ".*_([0-9]+)$" name) 0);
              };
              wifi = {
                mode = "infrastructure";
                ssid = "\$${name}__SSID";
                bssid = "\$${name}__BSSID";
              };
              wifi-security = {
                auth-alg = "open";
                key-mgmt = "wpa-psk";
                psk = "\$${name}__PSK";
              };
              ipv4 = {
                method = "auto";
              };
              ipv6 = {
                addr-gen-mode = "default";
                method = "auto";
              };
              proxy = { };
            };
          in
          {
            ax3_2 = mkProfile "AX3_2";
            ax3_5 = mkProfile "AX3_5";
            ax1500_5 = mkProfile "AX1500_5";
          };
      };
    };
  };

  hardware.alsa.enable = false;
  services = {
    xserver.enable = true;
    pipewire = {
      enable = true;
      package = pkgs-u.pipewire;
      audio.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber = {
        enable = true;
        package = pkgs-u.wireplumber;
      };
    };
    pulseaudio = {
      enable = false;
      support32Bit = true;
    };
    libinput.enable = true;
    openssh.enable = true;
    v2raya.enable = true;
    displayManager.lemurs = {
      enable = true;
    };
    seatd.enable = true;
    dbus.enable = true;
    lact.enable = true;
  };

  environment = {
    systemPackages = with pkgs-s; [
      nano
      git
      curl
      wget
      dmidecode
      lshw
      p7zip
      unzip
      parted
      exfat
      exfatprogs
      sops
      age
      ssh-to-age
      ventoy-full-gtk
      pkgs-u.waypipe
    ];
  };

  # https://github.com/NixOS/nix/issues/3995
  system.extraDependencies = [
    (pkgs-s.linkFarm "flake-inputs" (
      lib.map (name: {
        inherit name;
        path = "${inputs."${name}"}";
      }) (lib.attrNames inputs)
    ))
  ];
  programs = {
    mtr.enable = true;
  };

  services.xserver.excludePackages = [
    pkgs-s.xterm
  ];

  systemd.user.services.gpg-key-import = {
    description = "Import GPG private key from sops";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe (
        pkgs-s.writeShellApplication {
          name = "gpg-key";
          runtimeInputs = [
            pkgs-s.gnupg
          ];
          text = ''
            if ! gpg --list-secret-keys "0xE621ACCCFADEC0DE" > /dev/null 2>&1; then
              gpg --import ${config.sops.secrets."users/olimpik/gpg".path}
            fi
          '';
        }
      );
    };
  };

  system.stateVersion = "25.05";
}
