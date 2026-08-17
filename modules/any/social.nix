{
  system,
  config,
  osConfig,
  lib,
  lib-o,

  inputs,
  pkgs-s,
  pkgs-o,
  ...
}:
let
  cfg = config.my.social;
in
{
  options.my.social = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib-o.mkIf cfg.enable (
    let
      ayugram-desktop = inputs.ayugram-desktop.packages.${system}.ayugram-desktop;
    in
    {
      os = {
        nix.settings = {
          substituters = [
            "https://ayugram-desktop.cachix.org"
          ];
          extra-trusted-public-keys = [
            "ayugram-desktop.cachix.org:AZ5EqHrJsAKL5YkZYLPEsb1FdD9QlypUwQ0REcJftgA="
            "ayugram-desktop.cachix.org-1:AZ5EqHrJsAKL5YkZYLPEsb1FdD9QlypUwQ0REcJftgA="
          ];
        };
        environment.systemPackages = [
          ayugram-desktop
          pkgs-o.vesktop
        ];
      };
      hm = {
        home = {
          packages = [
            ayugram-desktop
            pkgs-o.vesktop
          ];
          file = {
            ".config/vesktop/settings/quickCss.css".source =
              lib-o.mkSymlink config "vesktop/settings/quickCss.css";
            ".config/vesktop/settings/settings.json".source =
              lib-o.mkSymlink config "vesktop/settings/settings.json";
            ".config/vesktop/settings.json".source = lib-o.mkSymlink config "vesktop/settings.json";
          };
        };
        my.wm.niri =
          let
            display = osConfig.my.wm.niri.display;
            output = if display.second != null then display.second else display.first;
            vesktop-width = if osConfig.my.host == "MS-7B85" then "fixed 940" else "proportion 0.5";
            ayugram-desktop-width = if osConfig.my.host == "MS-7B85" then "fixed 740" else "proportion 0.5";
          in
          {
            startups = ''
              ${config.my.wm.niri.run-visible} "${lib.getExe pkgs-o.vesktop}"
              ${config.my.wm.niri.run-visible} "${lib.getExe ayugram-desktop}:com.ayugram.desktop"
            '';
            workspaces = lib.mkOrder 1100 ''
              workspace "social" {
                  open-on-output "${output}"
              }
            '';
            windows = ''
              window-rule {
                  match app-id=r#"^vesktop$"#
                  default-column-width { ${vesktop-width}; }
                  open-on-workspace "social"
                  open-focused false
              }
              window-rule {
                  match app-id=r#"^com\.ayugram\.desktop$"#
                  exclude app-id=r#"^org\.ayugram\.desktop$"# title="Media viewer"
                  default-column-width { ${ayugram-desktop-width}; }
                  open-on-workspace "social"
                  open-focused false
              }
            '';
          };
      };
    }
  );
}
