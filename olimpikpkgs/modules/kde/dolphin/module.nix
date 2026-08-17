{
  config,
  lib,
  lib-o,

  pkgs-s,
  pkgs-o,
  ...
}:
let
  cfg = config.programs.dolphin;
in
{
  imports = [
    ./ffmpeg-compress.nix
    ./ffmpeg-convert.nix
    ./mediainfo.nix
    ./yazi.nix
  ];

  options.programs.dolphin = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    actions = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };

  config = lib-o.mkIf cfg.enable (
    let
      packages = [
        pkgs-o.kdePackages.dolphin
        pkgs-s.sshfs
        pkgs-s.kdePackages.konsole
        pkgs-s.kdePackages.kcmutils
        pkgs-s.kdePackages.kservice
        pkgs-s.kdePackages.kio
        pkgs-s.kdePackages.kio-extras
        pkgs-s.kdePackages.kio-fuse
        pkgs-s.kdePackages.kio-admin
        pkgs-s.kdePackages.ffmpegthumbs
        pkgs-s.kdePackages.kimageformats
        pkgs-s.kdePackages.qtimageformats
      ];
    in
    {
      os.environment.systemPackages = packages;
      hm = {
        home.packages = packages;
        xdg.dataFile =
          let
            mk-action =
              {
                name,
                types,
                icon,
                submenu ? null,
                actions,
              }:
              pkgs-s.writeTextFile {
                name = "${name}.desktop";
                text = ''
                  [Desktop Entry]
                  Type=Service
                  MimeType=${lib.concatStringsSep ";" types};
                  Icon=${icon}
                  Actions=${lib.concatStringsSep ";" (builtins.attrNames actions)};
                  ${lib.optionalString (submenu != null) "X-KDE-Submenu=${submenu}\n"}
                  ${lib.concatStringsSep "\n" (
                    lib.mapAttrsToList (actionName: action: ''
                      [Desktop Action ${actionName}]
                      Name=${action.name}
                      Icon=${action.icon or icon}
                      Exec=${action.exec}
                    '') actions
                  )}
                '';
                executable = true;
              };
            mk-actions =
              actions:
              lib.mapAttrs' (
                name: value:
                lib.nameValuePair "kio/servicemenus/${name}.desktop" {
                  source = "${mk-action ({ inherit name; } // value)}";
                }
              ) actions;
          in
          mk-actions config.programs.dolphin.actions;
      };
    }
  );
}
