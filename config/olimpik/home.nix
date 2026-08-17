{
  config,
  osConfig,
  lib,
  lib-o,

  pkgs-s,
  ...
}:
let
  email = "olimpik.net@gmail.com";
in
{
  imports = [
    ./theme.nix
    ./theme-manual.nix
  ];

  my = {
    gaming = {
      enable = true;
    };
    office = {
      enable = true;
    };
    social = {
      enable = true;
    };
    wm = {
      enable = true;
    };
    web = {
      enable = true;
    };
    development = {
      enable = true;
      nixos = {
        enable = true;
        startup = osConfig.my.host == "MS-7B85";
      };
      cpp = {
        enable = true;
        qt = osConfig.my.host == "MS-7B85";
        clion = true;
      };
      python = {
        enable = true;
      };
    };
    video = {
      enable = true;
      export = {
        enable = true;
      };
    };
    music = {
      enable = true;
      startup = osConfig.my.host == "MS-7B85";
    };
    theme = {
      enable = true;
      cursor = {
        enable = true;
        name = "gradient-green";
        path = "${lib-o.local config}/cursor";
      };
      icons = {
        enable = true;
        local = {
          "Local" = "${lib-o.local config}/icons";
        };
      };
    };
    monitoring = {
      enable = true;
    };
  };

  home = {
    username = "olimpik";
    homeDirectory = "/home/olimpik";

    packages = [
      pkgs-s.appimage-run
      pkgs-s.javaPackages.compiler.openjdk25
      pkgs-s.openssl
      pkgs-s.kdePackages.ksshaskpass
    ];

    file = {
      ".ssh/allowed_signers".text = ''
        ${email} ${builtins.readFile "${lib-o.local config}/ssh.pub"}
      '';
      ".ssh/id_ed25519.pub".source = "${lib-o.local config}/ssh.pub";
    };

    sessionVariables = {
      EDITOR = "code --wait";
      VISUAL = "code --wait";
      SSH_ASKPASS = "${lib.getExe pkgs-s.kdePackages.ksshaskpass}";
      SSH_ASKPASS_REQUIRE = "prefer";
    };

    stateVersion = "25.11";
  };

  programs = {
    home-manager = {
      enable = true;
    };
    bash = {
      enable = true;
      sessionVariables = {
        NIX_SHELL_PRESERVE_PROMPT = 1;
      };
      initExtra = ''
        export PS1="\[\e[35m\]$> \[\e[0m\]"
        ${builtins.readFile "${lib-o.local config}/scripts/init-extra.sh"}
      '';
      shellAliases = {
        btw = ''echo "''${USER^} use NixOS on ''${HOSTNAME,,} btw"'';
        n-s = ''sudo nixos-rebuild switch --flake "/home/$USER/NixOS/.#''${HOSTNAME,,}"'';
        n-b = ''sudo nixos-rebuild build --flake "/home/$USER/NixOS/.#''${HOSTNAME,,}" --profile-name "build-$(date +"%Y.%m.%d-%H.%M.%S")"'';
        h-s = ''home-manager build --flake "/home/$USER/NixOS/.#''${HOSTNAME,,}'';
        n-l = ''sudo nix-env --list-generations --profile "/nix/var/nix/profiles/system"'';
        n-d = ''sudo nix-env --delete-generations old --profile "/nix/var/nix/profiles/system"'';
        n-g = "sudo nix-collect-garbage -d";
        n-u = "my_nixos_update";
      };
    };
    alacritty = {
      enable = true;
      package = pkgs-s.alacritty.override {
        withGraphics = true;
      };
    };
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "Evgeniy Galyuta";
          email = email;
          signingkey = "0xE621ACCCFADEC0DE";
        };
        commit.gpgsign = true;
        gpg = {
          format = "openpgp";
          program = "gpg";
          ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        };
      };
    };
    gpg = {
      enable = true;
      publicKeys = [
        {
          source = "${lib-o.local config}/pgp.asc";
          trust = 5;
        }
      ];
    };
  };

  services = {
    ssh-agent = {
      enable = true;
    };
    gpg-agent = {
      enable = true;
      enableBashIntegration = true;
      sshKeys = [
        "AFA4E3F8773E250A27CB8BADC2016493"
      ];
      enableExtraSocket = true;
      enableScDaemon = true;
      pinentry.package = pkgs-s.pinentry-qt;
    };
    syncthing = {
      enable = true;
      settings = {
        devices = {
          "PC-MAIN" = {
            id = "3HQKCH7-6EUNKYB-BU3ROVA-44A5PV2-5BR6H2M-GUAYIPU-H7BN6WP-262BEAU";
          };
          "PC-MINI" = {
            id = "VERWADL-V2AJVEX-JRJQKHR-SSTBCWI-FNPGML2-WOHUTRV-3GP5FSU-C6A3UQ3";
          };
        };
        folders =
          let
            desktop-devices = [
              "PC-MAIN"
              "PC-MINI"
            ];
          in
          {
            "NixOS" = {
              path = "/home/olimpik/NixOS";
              devices = desktop-devices;
            };
          };
      };
    };
  };

  xdg = {
    configFile = {
      "swaylock/config".source = "${lib-o.local config}/swaylock";
    };
  };
}
