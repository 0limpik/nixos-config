{
  config,
  lib,
  lib-o,

  pkgs-s,
  pkgs-o,
  ...
}:
let
  cfg = config.my.explorer;
in
{
  options.my.explorer = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    dolphin = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    yazi = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib-o.mkConfig (
        let
          packages = [
            pkgs-s.kdePackages.ark
            pkgs-s.kdePackages.filelight
            pkgs-s.nerd-fonts.symbols-only
            pkgs-o.elio-fm
          ];
        in
        {
          os = {
            services.udisks2.enable = true;
            programs.kdeconnect.enable = true;
            environment.systemPackages = packages;
          };
          hm = {
            home.packages = packages;
            services.kdeconnect = {
              enable = true;
              indicator = true;
            };
            xdg.configFile = {
              "kdeglobals".source = lib-o.mkSymlink config "kde/kdeglobals.conf";
              "arkrc".source = lib-o.mkSymlink config "kde/arkrc";
              "filelightrc".source = lib-o.mkSymlink config "kde/filelightrc";
              "iconexplorerrc".source = lib-o.mkSymlink config "kde/iconexplorerrc";
              "konsolerc".source = lib-o.mkSymlink config "kde/konsolerc";
            };
          };
        }
      ))
      (lib-o.mkIf cfg.dolphin {
        hm = {
          programs.dolphin = {
            enable = true;
            ffmpeg-compress = true;
            ffmpeg-convert = true;
            mediainfo = true;
            yazi = true;
          };
          xdg.dataFile = {
            "dolphinrc".source = lib-o.mkSymlink config "kde/dolphinrc.conf";
            "user-places.xbel".source = lib-o.mkSymlink config "kde/user-places.xbel";
          };
        };
      })
      (lib-o.mkIf cfg.yazi {
        any = {
          nix.settings = {
            substituters = [
              "https://yazi.cachix.org"
            ];
            extra-trusted-public-keys = [
              "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
            ];
          };
          programs.yazi = {
            enable = true;
            plugins = lib.listToAttrs (
              lib.map (pkg: lib.nameValuePair (lib.removeSuffix ".yazi" pkg.pname) pkg) (
                with pkgs-s.yaziPlugins;
                [
                  chmod
                  compress
                  convert
                  diff
                  drag
                  git
                  githead
                  mediainfo
                  mime-ext
                  ouch
                  piper
                  rich-preview
                  sshfs
                ]
              )
            );
          };
        };
        os = {
          environment.etc."xdg/menus/applications.menu".source = pkgs-s.fetchurl {
            url = "https://raw.githubusercontent.com/qweered/hyprnixos/refs/heads/main/assets/dolphin.menu";
            hash = "sha256-pVvOXRPvpsnhmGEAldOKpOuGJXo2cNSIQidecm5wK/Y=";
          };
        };
        hm = {
          programs.yazi.shellWrapperName = "yazi";
        };
      })
    ]
  );
}
