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
    mediainfo = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib-o.mkIf (cfg.enable && cfg.mediainfo) {
    hm.programs.dolphin.actions.mediainfo = {
      types = [
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/quicktime"
        "video/h264"
        "audio/aac"
        "audio/ogg"
        "audio/x-wav"
        "audio/flac"
        "image/jpeg"
        "image/png"
        "image/gif"
        "image/webp"
        "image/tiff"
        "image/bmp"
      ];
      icon = "mkvinfo";
      actions = {
        "mediainfo-kdialog" = {
          name = "MediaInfo";
          exec = "${
            lib.getExe (
              pkgs-s.writeShellApplication rec {
                name = "mediainfo-kdialog";
                runtimeInputs = [
                  pkgs-s.mediainfo
                  pkgs-s.gawk
                  pkgs-s.kdePackages.kdialog
                ];
                text = ''
                  mediainfo "$1" \
                  | awk '{print "<pre style=\"margin:0px;padding:0px;\"><font size=\"1\">" $0 "</font></pre>"}' \
                  | kdialog --textbox - 1000 1080
                '';
                meta.mainProgram = name;
              }
            )
          } %U";
        };
      };
    };
  };
}
