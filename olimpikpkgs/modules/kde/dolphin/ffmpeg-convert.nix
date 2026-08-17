{
  config,
  lib,
  lib-o,

  pkgs-s,
  ...
}:
let
  cfg = config.programs.dolphin;
in
{
  options.programs.dolphin = {
    ffmpeg-convert = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib-o.mkIf (cfg.enable && cfg.ffmpeg-convert) {
    hm.programs.dolphin.actions =
      let
        ffmpeg-convert = pkgs-s.writeShellApplication {
          name = "ffmpeg-convert";
          runtimeInputs = with pkgs-s; [
            kdePackages.kdialog
            ffmpeg
          ];
          text = builtins.readFile ./ffmpeg-convert;
        };
      in
      {
        ffmpeg-convert-png = {
          types = [
            "image/png"
          ];
          icon = "ffmpeg";
          submenu = "Convert";
          actions = {
            "png-to-jpeg" = {
              name = "JPEG";
              exec = "${lib.getExe ffmpeg-convert} .jpg %U";
            };
            "png-to-webp" = {
              name = "WEBP";
              exec = "${lib.getExe ffmpeg-convert} .webp %U";
            };
          };
        };
        ffmpeg-convert-jpeg = {
          types = [
            "image/jpeg"
          ];
          icon = "ffmpeg";
          submenu = "Convert";
          actions = {
            "jpeg-to-png" = {
              name = "PNG";
              exec = "${lib.getExe ffmpeg-convert} .png %U";
            };
            "jpeg-to-webp" = {
              name = "WEBP";
              exec = "${lib.getExe ffmpeg-convert} .webp %U";
            };
          };
        };
        ffmpeg-convert-webm = {
          types = [
            "image/webp"
          ];
          icon = "ffmpeg";
          submenu = "Convert";
          actions = {
            "webp-to-png" = {
              name = "PNG";
              exec = "${lib.getExe ffmpeg-convert} .png %U";
            };
            "webp-to-jpeg" = {
              name = "JPEG";
              exec = "${lib.getExe ffmpeg-convert} .jpg %U";
            };
          };
        };
      };
  };
}
