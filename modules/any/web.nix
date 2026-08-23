{
  config,
  osConfig,
  lib,
  lib-o,

  pkgs-s,
  pkgs-m,
  ...
}:
let
  cfg = config.my.web;
in
{
  options.my.web = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    browser = lib.mkOption {
      type = lib.types.package;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      ({
        my.web.browser = pkgs-s.google-chrome;
        my.wm.niri =
          let
            windowName = "Main Browser";
          in
          {
            startups = ''
              ${config.my.wm.niri.run-visible} "${lib.getExe cfg.browser}:google-chrome" "--window-name=${windowName}"
            '';
            workspaces = lib.mkOrder 1150 ''
              workspace "browser" {
                  open-on-output "${(if osConfig ? my then osConfig else config).my.wm.niri.display.first}"
              }
            '';
            windows = ''
              window-rule {
                  match app-id=r#"^google-chrome$"# title=r#"^${windowName}$"#
                  open-on-workspace "browser"
                  open-maximized-to-edges true
                  open-focused true
              }
            '';
          };
      })
      (lib-o.mkConfig (
        let
          packages = [
            pkgs-s.curl
            pkgs-s.wget
          ];
        in
        {
          os.environment.systemPackages = packages;
          hm.home.packages = packages;
        }
      ))
      (lib-o.mkIf config.my.wm.enable (
        let
          nomachine-client = pkgs-m.nomachine-client.overrideAttrs (
            attrs:
            let
              myMajor = "10.0";
              myMinor = "57";
              myPatch = "1";
              myVersion = "${myMajor}.${myMinor}";
              isMy = (builtins.compareVersions myVersion attrs.version) == 1;
            in
            rec {
              version = if isMy then "${myVersion}.${myPatch}" else attrs.version;
              src = attrs.src.overrideAttrs (attrs: {
                inherit version;
                urls =
                  if isMy then
                    [
                      "https://web9001.nomachine.com/download/${myMajor}/Linux/nomachine-personal-edition_${myVersion}_${myPatch}_x86_64.tar.gz"
                    ]
                  else
                    attrs.urls;
                hash = if isMy then "sha256-5jeGX1H92zKnO1qGv0/0oVdS2AhSlrDZsfmD/RqT0Ak=" else attrs.hash;
              });
            }
          );
          packages = [
            cfg.browser
            pkgs-s.qbittorrent
            nomachine-client
            pkgs-s.rustdesk
          ];
        in
        {
          os.environment.systemPackages = packages;
          hm.home.packages = packages;
        }
      ))
    ]
  );
}
