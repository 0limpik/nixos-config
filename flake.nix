{
  description = "Olimpik NixOS configuration";

  inputs = {
    nixpkgs-s.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-u.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-m.url = "github:nixos/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-s";
    };

    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };

    olimpikpkgs = {
      url = "path:./olimpikpkgs";
      inputs.nixpkgs-s.follows = "nixpkgs-s";
      inputs.nixpkgs-u.follows = "nixpkgs-u";
      inputs.nixpkgs-m.follows = "nixpkgs-m";
      inputs.flake-compat.follows = "flake-compat";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs-s";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-s";
    };

    catppuccin = {
      url = "github:catppuccin/nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-s";
    };

    vicinae = {
      url = "github:vicinaehq/vicinae/v0.26.3"; # auto_bump_tag
      inputs.nixpkgs.follows = "nixpkgs-s";
    };

    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs-s";
      inputs.flake-compat.follows = "flake-compat";
      inputs.vicinae.follows = "vicinae";
    };

    ayugram-desktop = {
      url = "https://github.com/ndfined-crp/ayugram-desktop/";
      type = "git";
      submodules = true;
      inputs.nixpkgs.follows = "nixpkgs-u";
      inputs.tg_owt.inputs.nixpkgs.follows = "nixpkgs-u";
    };

    nix-jetbrains-plugins = {
      url = "github:nix-community/nix-jetbrains-plugins";
      inputs.nixpkgs.follows = "nixpkgs-u";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs-s,
      nixpkgs-u,
      nixpkgs-m,
      home-manager,
      olimpikpkgs,
      ...
    }:
    let
      args = {
        system = "x86_64-linux";
      };
      pkgs-u = import ./olimpikpkgs/config/nixpkgs-u.nix args nixpkgs-u;
      args.nix-update-script = pkgs-u.nix-update-script;
      pkgs-s = import ./olimpikpkgs/config/nixpkgs-s.nix args nixpkgs-s;
      pkgs-m = import ./olimpikpkgs/config/nixpkgs-m.nix args nixpkgs-m;
      pkgs-o = olimpikpkgs.packages."${args.system}";
      lib-o =
        source:
        olimpikpkgs.lib."${args.system}" {
          inherit source;
          path = ./.;
          inherit (pkgs-s) lib;
        };

      baseArgs = {
        inherit (args) system;
        inherit
          inputs
          pkgs-s
          pkgs-u
          pkgs-m
          pkgs-o
          ;
      };
      systemArgs = {
        inherit (args) system;
        pkgs = pkgs-s;
        specialArgs = baseArgs // {
          lib-o = lib-o "system";
          osConfig = null;
          isSystem = true;
          packages = pkgs: {
            environment.systemPackages = pkgs;
          };
        };
      };
      homeArgs = baseArgs // {
        lib-o = lib-o "home";
        isSystem = false;
        packages = pkgs: {
          home.packages = pkgs;
        };
      };
      modules = [
        ./config/.
        ./config/olimpik/.
        olimpikpkgs.homeManagerModules
        ./modules/module-list.nix
        inputs.sops-nix.nixosModules.sops
        ./config/sops.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            extraSpecialArgs = homeArgs;
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
              olimpikpkgs.homeManagerModules
              ./modules/module-list.nix
            ];
            users.olimpik = ./config/olimpik/home.nix;
          };
        }
        inputs.catppuccin.nixosModules.catppuccin
      ];
    in
    {
      nixosConfigurations = {
        pc-main = nixpkgs-s.lib.nixosSystem (
          systemArgs
          // {
            modules = modules ++ [
              ./config/MS-7B85
            ];
          }
        );
        pc-mini = nixpkgs-s.lib.nixosSystem (
          systemArgs
          // {
            modules = modules ++ [
              ./config/G1619-04
            ];
          }
        );
      };
      homeConfigurations = {
        olimpik = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = homeArgs;
          pkgs = pkgs-s;
          modules = [
            inputs.sops-nix.homeManagerModules.sops
            olimpikpkgs.homeManagerModules
            ./config/sops.nix
            ./config/olimpik/home.nix
            ./modules/module-list.nix
          ];
        };
      };
    };
}
