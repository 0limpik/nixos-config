{
  steam,
  callPackage,
  buildFHSEnv,
  bubblewrap,
  vr ? false,
  ...
}:
let
  bubblewrap-vr = callPackage ./bubblewrap.nix { };
  bubblewrap-final = if vr then bubblewrap-vr else bubblewrap;
  steam-with-vr =
    if vr then
      steam.override {
        buildFHSEnv =
          args:
          (
            (buildFHSEnv.override {
              bubblewrap = bubblewrap-vr;
            })
            (
              args
              // {
                extraBwrapArgs = (args.extraBwrapArgs or [ ]) ++ [ "--cap-add ALL" ];
              }
            )
          );
        extraLibraries = pkgs: [
          pkgs.libxcb
        ];
        extraPkgs =
          pkgs: with pkgs; [
            libxcursor
            libxi
            libxinerama
            libxscrnsaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
            gamemode
          ];
      }
    else
      steam;
in
steam-with-vr.overrideAttrs (attrs: {
  passthru = (attrs.passthru or { }) // {
    bubblewrap = bubblewrap-final;
  };
})
