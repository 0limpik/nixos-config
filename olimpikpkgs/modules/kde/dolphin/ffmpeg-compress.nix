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
    ffmpeg-compress = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib-o.mkIf (cfg.enable && cfg.ffmpeg-compress) {
    hm.programs.dolphin.actions =
      let
        /*
          ffmpeg-compress = stable.writeShellApplication {
            name = "ffmpeg-compress";
            runtimeInputs = with stable; [
              kdePackages.kdialog
              kdePackages.qttools
              ffmpeg
            ];
            text = builtins.readFile ../configurations/olimpik/scripts/ffmpeg-compress.sh;
          };
        */
      in
      {
        /*
          ffmpeg-compress-mp4 = {
            types = [
              "video/mp4"
            ];
            icon = "ffmpeg";
            submenu = "Convert";
            actions =
              let
                audio-acc = "--audio \"aac -b:a 80k -ar 48000 -ac 2\"";
              in
              {
                "mp4-compress-10MB" = {
                  name = "10MB";
                  exec = "${lib.getExe ffmpeg-compress} --size 10 %U";
                };
                "mp4-compress-10MB-aac" = {
                  name = "10MB AAC";
                  exec = "${lib.getExe ffmpeg-compress} --size 10 ${audio-acc} %U";
                };
                "mp4-compress-10MB-720p" = {
                  name = "10MB 720p";
                  exec = "${lib.getExe ffmpeg-compress} --size 10 --height 720 %U";
                };
                "mp4-compress-10MB-720p-aac" = {
                  name = "10MB 720p ACC";
                  exec = "${lib.getExe ffmpeg-compress} --size 10 --height 720 ${audio-acc} %U";
                };
              };
          };
        */
      };
  };
}
