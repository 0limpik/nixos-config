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
      nixpkgsBaseArgs = {
        system = "x86_64-linux";
      };
      nixpkgsArgs = nixpkgsBaseArgs // {
        nix-update-script = pkgs-u.nix-update-script;
      };
      pkgs-s = import ./config/nixpkgs-s.nix nixpkgsArgs nixpkgs-s;
      pkgs-u = import ./config/nixpkgs-u.nix nixpkgsBaseArgs nixpkgs-u;
      pkgs-m = import ./config/nixpkgs-m.nix nixpkgsArgs nixpkgs-m;
    in
    rec {
      lib."${nixpkgsBaseArgs.system}" = import ./lib/default.nix;
      packages."${nixpkgsBaseArgs.system}" = import ./pkgs/all-packages.nix {
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
        pkgs = packages."${nixpkgsBaseArgs.system}";
      };
    };
}
