{
  description = "A collection of packages for the Nix package manager by Olimpik";

  inputs = {
    nixpkgs-s.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-u.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-m.url = "github:nixos/nixpkgs/master";
    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs-s,
      nixpkgs-u,
      nixpkgs-m,
      ...
    }:
    let
      args = {
        system = "x86_64-linux";
      };
      pkgs-u = import ./config/nixpkgs-u.nix args nixpkgs-u;
      args.nix-update-script = pkgs-u.nix-update-script;
      pkgs-s = import ./config/nixpkgs-s.nix args nixpkgs-s;
      pkgs-m = import ./config/nixpkgs-m.nix args nixpkgs-m;
    in
    rec {
      lib."${args.system}" = import ./lib/default.nix;
      packages."${args.system}" = import ./pkgs/all-packages.nix {
        inherit (pkgs-s) lib newScope;
        inherit
          pkgs-s
          pkgs-u
          pkgs-m
          ;
      };
      legacyPackages = packages;
      nixosManagerModules = import ./modules/module-list.nix;
      homeManagerModules = import ./modules/module-list.nix;
      maintained = import ./lib/maintained.nix {
        lib = pkgs-s.lib;
        pkgs = packages."${args.system}";
      };
    };
}
