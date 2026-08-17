{
  config,
  lib,
  lib-o,

  pkgs-s,
  pkgs-o,
  ...
}:
let
  cfg = config.my.video;
in
{
  options.my.video = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    import = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
    export = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      blackmagic = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib-o.mkIf cfg.import.enable (
        let
          packages = [
            pkgs-s.vlc
          ];
        in
        {
          os.environment.systemPackages = packages;
          hm.home.packages = packages;
        }
      ))
      (lib.mkIf cfg.export.enable (
        lib.mkMerge [
          (lib-o.mkConfig (
            let
              packages = [
                pkgs-o.ffmpeg
                pkgs-s.yt-dlp
                pkgs-s.mediainfo
                pkgs-o.handbrake
                pkgs-o.shutter-encoder
              ];
            in
            {
              os.environment.systemPackages = packages;
              hm.home.packages = packages;
              any.programs = {
                obs-studio = {
                  enable = true;
                };
              };
            }
          ))
          (lib-o.mkIf cfg.export.blackmagic (
            let
              davinci-resolve-studio = pkgs-o.davinci-resolve-studio.withEncoders (
                with pkgs-o.davinci-resolve-encoders.override {
                  uniform-names = true;
                };
                [
                  ffmpeg
                  vaapi
                  x264
                  x265
                  x265-10b
                  prores-U
                  prores-j
                  aac
                  aac-fdk
                ]
              );
            in
            {
              os.environment.systemPackages = [ davinci-resolve-studio ];
              hm.home.packages = [ davinci-resolve-studio ];
            }
          ))
        ]
      ))
    ]
  );
}
