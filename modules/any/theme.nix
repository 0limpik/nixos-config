{
  config,
  lib,
  lib-o,

  inputs,
  pkgs-s,
  pkgs-o,
  ...
}:
let
  cfg = config.my.theme;

  shiftColor =
    hex: amount:
    let
      c = lib.removePrefix "#" hex;
      r = builtins.substring 0 2 c;
      g = builtins.substring 2 2 c;
      b = builtins.substring 4 2 c;
      shift =
        hex:
        let
          decimal = (lib.fromHexString hex) + amount;
          clamped =
            if decimal < 0 then
              0
            else if decimal > 255 then
              255
            else
              decimal;
          rawHex = lib.toHexString clamped;
        in
        if clamped < 16 then "0${rawHex}" else rawHex;
    in
    "#${shift r}${shift g}${shift b}";
in
{
  options.my.theme = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    icons = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      local = lib.mkOption {
        type = lib.types.attrsOf lib.types.path;
        default = { };
      };
    };
    cursor = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      name = lib.mkOption {
        type = lib.types.str;
      };
      path = lib.mkOption {
        type = lib.types.path;
      };
    };
    colorScheme = {
      flavor = lib.mkOption {
        type = lib.types.str;
      };
      accent = lib.mkOption {
        type = lib.types.str;
      };
      palette = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
      };
    };
  };

  config = lib-o.mkIf cfg.enable (
    let
      colorScheme = cfg.colorScheme // {
        palette =
          cfg.colorScheme.palette
          // (lib.mapAttrs' (
            name: value: lib.nameValuePair "light-${name}" (shiftColor value 20)
          ) cfg.colorScheme.palette)
          // (lib.mapAttrs' (
            name: value: lib.nameValuePair "dark-${name}" (shiftColor value (-20))
          ) cfg.colorScheme.palette)
          // rec {
            accent = cfg.colorScheme.palette."${cfg.colorScheme.accent}";
            light-accent = shiftColor accent 20;
            dark-accent = shiftColor accent (-20);
          };
      };
    in
    {
      os = {
        console.colors =
          let
            colored = with colorScheme.palette; [
              red
              green
              yellow
              blue
              mauve
              teal
            ];
            colors =
              with colorScheme.palette;
              [ base ]
              ++ colored
              ++ [
                text
                surface2
              ]
              ++ (lib.map (c: shiftColor c 20) colored)
              ++ [ subtext0 ];
          in
          lib.map (c: lib.removePrefix "#" c) colors;
        services.displayManager.lemurs.settings = {
          environment_switcher = {
            mover_color_focused = "magenta";
            no_envs_color_focused = "magenta";
          };
          username_field.style = {
            title_color_focused = "magenta";
            content_color_focused = "magenta";
            border_color_focused = "magenta";
          };
          password_field.style = {
            title_color_focused = "magenta";
            content_color_focused = "magenta";
            border_color_focused = "magenta";
          };
        };
        environment.systemPackages = [
          pkgs-s.libsForQt5.qtstyleplugin-kvantum
          pkgs-s.kdePackages.qtstyleplugin-kvantum
          pkgs-s.qt6Packages.qtstyleplugin-kvantum
        ];
      };
      hm = lib.mkMerge [
        {
          home.packages = [
            pkgs-s.libsForQt5.qtstyleplugin-kvantum
            pkgs-s.kdePackages.qtstyleplugin-kvantum
            pkgs-s.qt6Packages.qtstyleplugin-kvantum
          ];
          catppuccin.sources = inputs.catppuccin.packages.${pkgs-s.stdenv.hostPlatform.system}.overrideScope (
            final: prev: {
              whiskers = pkgs-s.catppuccin-whiskers;
              alacritty =
                pkgs-s.runCommand "catppuccin-alacritty"
                  {
                    nativeBuildInputs = [
                      pkgs-s.yq-go
                    ];
                  }
                  ''
                    mkdir --parents "$out"
                    cp "${prev.alacritty}"/*.toml "$out"
                    chmod --recursive +w "$out"
                    yq \
                      --inplace \
                      --input-format toml \
                      --output-format toml '
                        .colors.normal.magenta = "${colorScheme.palette.mauve}"
                        | .colors.bright.magenta = "${colorScheme.palette.light-mauve}"
                      ' "$out/catppuccin-${colorScheme.flavor}.toml"
                  '';
              vscode = prev.vscode.overrideAttrs (attrs: {
                nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ ([
                  pkgs-s.jq
                ]);
                postInstall = ''
                  theme_path="$out/share/vscode/extensions/catppuccin.vscode/themes/mocha.json"
                  temp_theme_path="$(mktemp)"
                  jq --raw-output '
                    .colors["terminal.ansiMagenta"] = "${colorScheme.palette.mauve}"
                    | .colors["terminal.ansiBrightMagenta"] = "${colorScheme.palette.light-mauve}"
                  ' "$theme_path" > "$temp_theme_path" && mv "$temp_theme_path" "$theme_path"
                '';
              });
            }
          );
          my.wm.niri.themes =
            let
              palette = colorScheme.palette;
            in
            ''
              layout {
                  background-color "${palette.crust}"
                  border {
                      active-color "${palette.accent}"
                      inactive-color "${palette.text}"
                      urgent-color "${palette.light-accent}"
                  }
                  shadow {    
                      color "${palette.accent}"
                      inactive-color "${palette.crust}00"
                  }
                  focus-ring {
                      active-color "${palette.accent}"
                      inactive-color "${palette.text}"
                      urgent-color "${palette.light-accent}"
                  }
                  tab-indicator {
                      active-color "${palette.accent}"
                      inactive-color "${palette.text}"
                      urgent-color "${palette.light-accent}"
                  }
                  insert-hint {
                      color "${palette.accent}"
                  }
              }
              overview {
                  backdrop-color "${shiftColor palette.crust (-15)}"
                  workspace-shadow {
                      color "${palette.text}"
                  }
              }
              recent-windows {
                  highlight {
                      active-color "${palette.accent}"
                      urgent-color "${palette.light-accent}"
                  }
              }
            '';
        }
        (lib.mkIf cfg.cursor.enable (
          let
            name = cfg.cursor.name;
            package = pkgs-s.runCommand name { } ''
              mkdir --parents "$out/share/icons"
              ln --symbolic --no-target-directory \
                "${cfg.cursor.path}" "$out/share/icons/${name}"
            '';
            size = 24;
          in
          {
            home = {
              pointerCursor = {
                enable = true;
                inherit name package size;
                gtk.enable = true;
                x11 = {
                  enable = true;
                  inherit size;
                };
              };
            };
          }
        ))
        (lib.mkIf cfg.icons.enable (
          let
            catppuccin-icons = pkgs-o.catppuccin.icons.override {
              inherit colorScheme;
              icons = {
                "Material-Design" = pkgs-o.material-design-icons.override {
                  inherit colorScheme;
                };
              }
              // builtins.mapAttrs (
                name: path:
                pkgs-o.local-icons.override {
                  inherit colorScheme;
                  icons = path;
                }
              ) cfg.icons.local;
            };
          in
          {
            home.packages = [
              catppuccin-icons
              pkgs-s.catppuccin-whiskers
            ];
            gtk = {
              iconTheme = {
                name = "Papirus-Dark";
                package = catppuccin-icons;
              };
            };
          }
        ))
      ];
    }
  );
}
