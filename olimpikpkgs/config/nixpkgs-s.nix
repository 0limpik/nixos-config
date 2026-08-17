system: pkgs:
let
  config = import ./nixpkgs.nix { inherit (pkgs) lib; };
in
import pkgs {
  inherit system;
  config = {
    allowUnfreePredicate = config.allowUnfreePredicate "s" [
      "google-chrome"
      "vscode"
      "corefonts"
      "vista-fonts"
      "discord"
      "libsciter"
      "davinci-resolve-studio"
      "blackmagic-desktop-video"
      "ventoy-qt5"
      "ventoy-gtk3"
      "7zz"
      "uasm"
      "steam"
      "steam-unwrapped"
      "steam-run"
      "xnviewmp"
    ];
    allowInsecurePredicate = config.allowInsecurePredicate "s" [
      "dcraw"
      "ventoy-qt5"
      "ventoy-gtk3"
      "xpdf"
    ];
  };
  overlays = [
    config.overlay
    (final: prev: {
      xdg-desktop-portal = prev.xdg-desktop-portal.overrideAttrs (attrs: {
        patches = builtins.filter (
          patch: builtins.baseNameOf (toString patch) != "nix-pkgdatadir-env.patch"
        ) (attrs.patches or [ ]);
      });
    })
  ];
}
