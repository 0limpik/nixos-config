{
  lib,
  newScope,

  pkgs-s,
  pkgs-u,
  pkgs-m,
}:
builtins.removeAttrs
  (lib.makeScope newScope (
    scope:
    let
      callPackage = scope.callPackage;
      callPackage-s = pkgs-s.callPackage;
      callPackage-u = pkgs-u.callPackage;
      callPackage-m = pkgs-m.callPackage;
    in
    {
      bmx = callPackage ./bmx/package.nix { };
      catppuccin = {
        icons = callPackage ./catppuccin/icons.nix { };
      };
      davinci-resolve-studio = callPackage ./davinci-resolve/license.nix {
        path = ./davinci-resolve/package.nix;
      };
      davinci-resolve-encoders = callPackage ./davinci-resolve/encoders { };
      elio-fm = callPackage ./elio-fm/package.nix { };
      ffmpeg = callPackage-u ./ffmpeg/package.nix { };
      handbrake = callPackage-u ./handbrake/package.nix { };
      kdePackages = callPackage-s ./kde { };
      local-icons = callPackage ./local-icons/package.nix { };
      material-design-icons = callPackage ./material-design-icons/package.nix { };
      mission-center = callPackage-s ./mission-center/package.nix { };
      nixos-editor = callPackage ./nixos-editor/package.nix { };
      nix-update = callPackage-s ./nix-update/package.nix { };
      shutter-encoder = callPackage ./shutter-encoder/package.nix { };
      spotify-browser = callPackage ./spotify-browser/package.nix { };
      steam = callPackage-u ./steam/package.nix {
        steam = pkgs-u.steam;
      };
      tsmuxer = callPackage ./tsmuxer/package.nix { };
      vesktop = callPackage-m ./vesktop/package.nix {
        inherit (pkgs-u) electron_43;
      };
      vscode-extensions = callPackage-s ./vscode-extensions { };
    }
  ))
  [
    "packages"
  ]
