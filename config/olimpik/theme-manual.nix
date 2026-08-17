{
  config,
  lib,
  lib-o,

  inputs,
  pkgs-s,
  ...
}:
let
  catppuccin = config.my.theme.colorScheme;
in
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  home = {
    packages = [
      pkgs-s.catppuccin
      pkgs-s.catppuccin-gtk
      pkgs-s.catppuccin-grub
      pkgs-s.catppuccin-qt5ct
      (pkgs-s.catppuccin-kvantum.override {
        variant = catppuccin.flavor;
        inherit (catppuccin) accent;
      })
    ];
    sessionVariables = {
      QT_QUICK_CONTROLS_STYLE = "Fusion";
    };
  };

  fonts = {
    fontconfig = {
      defaultFonts = {
        serif = [ "Rajdhani NeU" ];
        sansSerif = [ "Rajdhani NeU" ];
        monospace = [ "Lekton" ];
      };
    };
  };

  catppuccin = {
    enable = true;
    cache.enable = true;
    vesktop.enable = false;
    gtk.icon.enable = false;
    qt5ct.enable = false;
    kvantum.enable = false;
    vicinae.enable = false;
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    kvantum.enable = false;
  };

  gtk =
    let
      theme = {
        name = "Catppuccin-GTK-Mauve-Dark-Compact";
        package = pkgs-s.magnetic-catppuccin-gtk.override {
          tweaks = [ "black" ];
          shade = "dark";
          accent = [ catppuccin.accent ];
          size = "compact";
        };
      };
    in
    {
      enable = true;
      colorScheme = "dark";
      gtk3.theme = theme;
      gtk4.theme = theme;
    };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
  };

  xdg = {
    configFile = {
      "yazi/theme.toml".source = lib.mkForce (
        pkgs-s.runCommand "yazi-theme.toml"
          {
            src = inputs.catppuccin.packages."${pkgs-s.stdenv.hostPlatform.system}".sources.yazi;
            nativeBuildInputs = [
              pkgs-s.yq-go
              pkgs-s.yj
            ];
          }
          ''
            cp $src/themes/${catppuccin.flavor}/catppuccin-${catppuccin.flavor}-${catppuccin.accent}.toml ./config.toml
            yq -p=toml -o=json \
              '(.filetype.rules[]
                | select(has("name")))
                |= (.url = .name
                  | del(.name))' \
              config.toml \
            | yj -jt > $out
          ''
      );
    }
    // {
      "qt5ct/qt5ct.conf".source = lib-o.mkSymlink config "qtct/qt5ct.conf";
      "qt5ct/style-colors.conf".source = lib-o.mkSymlink config "qtct/style-colors.conf";
      "qt6ct/qt6ct.conf".source = lib-o.mkSymlink config "qtct/qt6ct.conf";
      "qt6ct/style-colors.conf".source = lib-o.mkSymlink config "qtct/style-colors.conf";
    }
    // (
      let
        qtcreator = pkgs-s.fetchFromGitHub {
          owner = "catppuccin";
          repo = "qtcreator";
          rev = "main";
          hash = "sha256-LlQH0unBk5UlvGIp/dENiB+PS3D2pwiarmPX6+u8mtc=";
        };
      in
      {
        "QtProject/qtcreator/styles".source = "${qtcreator}/styles";
        "QtProject/qtcreator/themes".source = "${qtcreator}/themes";
      }
    )
    // (lib.listToAttrs (
      map
        (
          path:
          lib.nameValuePair "Kvantum/${path}" {
            source = lib-o.mkSymlink config "kvantum/${path}";
          }
        )
        [
          "kvantum.kvconfig"
          "catppuccin-mocha-mauve/catppuccin-mocha-mauve.kvconfig"
          "catppuccin-mocha-mauve/catppuccin-mocha-mauve.svg"
        ]
    ));
    dataFile = {
      "fonts/Blender-Pro.otf".source = "${lib-o.local config}/blender/Blender-Pro.otf";
      "fonts/Blender-Pro-Bold.otf".source = "${lib-o.local config}/blender-pro/Blender-Pro-Bold.otf";
      "fonts/Lekton-Regular.ttf".source = "${lib-o.local config}/lekton/Lekton-Regular.ttf";
      "fonts/Lekton-Bold.ttf".source = "${lib-o.local config}/lekton/Lekton-Bold.ttf";
      "fonts/Lekton-Italic.ttf".source = "${lib-o.local config}/lekton/Lekton-Italic.ttf";
      #"fonts/Rajdhani.ttf".source = "${lib-o.local}/fonts/rajdhani/Rajdhani.ttf";
      #"fonts/Rajdhani-Regular.ttf".source = "${lib-o.local}/fonts/rajdhani/Rajdhani-Regular.ttf";
      #"fonts/Rajdhani-Bold.ttf".source = "${lib-o.local}/fonts/rajdhani/Rajdhani-Bold.ttf";
      "fonts/Rajdhani-Medium.ttf".source = "${lib-o.local config}/fonts/rajdhani/Rajdhani-Medium-NEU.ttf";
      "fonts/Rajdhani-Semibold.ttf".source =
        "${lib-o.local config}/fonts/rajdhani/Rajdhani-Semibold-RU.ttf";
      "fonts/JetBrainsMono.ttf".source = "${lib-o.local config}/fonts/jetbrains/JetBrainsMono.ttf";
      "color-schemes/CatppuccinMochaMauve.colors".source = "${
        (pkgs-s.catppuccin-kde.override {
          flavour = [ catppuccin.flavor ];
          accents = [ catppuccin.accent ];
        })
      }/share/color-schemes/CatppuccinMochaMauve.colors";
    }
    // (
      let
        catfa = "cat-${catppuccin.flavor}-${catppuccin.accent}";
        catf = "cat-${catppuccin.flavor}";
      in
      lib.mapAttrs'
        (
          dir: icon:
          lib.nameValuePair "dolphin/view_properties/local/${config.home.homeDirectory}/${dir}/.directory" {
            source = pkgs-s.writeText (lib.replaceStrings [ "/" ] [ "-" ] dir) ''
              [Desktop Entry]
              Icon=${icon}
            '';
          }
        )
        {
          "NixOS" = "folder-nixos-stable";
          ".nix-defexpr" = "folder-nixos";
          ".nix-profile" = "folder-nixos";
          "Sources" = "folder-${catfa}-code";
          "Projects" = "folder-${catfa}-projects";
          "Applications" = "folder-${catfa}-applications";
          "Downloads" = "folder-${catfa}-download";
          "Downloads/AyuGram Desktop" = "folder-${catfa}-download";
          "Games" = "folder-${catfa}-games";
          "Pictures" = "folder-${catfa}-pictures";
          "Desktop" = "folder-${catfa}-desktop";
          "Documents" = "folder-${catfa}-documents";
          "Videos" = "folder-${catfa}-video";
          "Systems" = "folder-${catfa}-cd";
          ".icons" = "folder-icons";
          ".ssh" = "ssh";
          ".npm" = "npm";
          ".gnupg" = "gnupg";
          ".wine" = "folder-${catfa}-wine";
          ".steam" = "folder-${catfa}-steam";
          ".backup" = "folder-${catfa}-backup";
          ".config" = "folder-${catf}-peach-applications";
          ".local" = "folder-${catf}-peach-applications";
          ".local/state" = "material-design-arrow_downward-sharp";
          ".local/share" = "material-design-arrow_upward-sharp";
          ".cache" = "folder-${catf}-peach-visiting";
          ".compose-cache" = "folder-${catf}-peach-visiting";
          ".vscode" = "vscode";
          ".vscode-shared" = "vscode";
          ".factorio" = "factorio";
          ".renderdoc" = "renderdoc";
          ".RadeonGPUProfiler" = "radeon-profile";
          ".RadeonMemoryVisualizer" = "radeon-profile";
          ".rga" = "radeon-profile";
          ".android" = "folder-${catfa}-android";
          ".nuget" = "nuget";
          ".dotnet" = "dotnet";
          ".renpy" = "renpy";
          ".java" = "folder-${catfa}-java";
          ".pki" = "keyring-manager";
        }
    );
  };
}
