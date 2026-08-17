{
  lib,
  makeDesktopItem,
  writeShellScriptBin,
  symlinkJoin,

  google-chrome,
  browser ? google-chrome,
}:
let
  app = writeShellScriptBin "spotify-browser" ''
    exec ${lib.getExe browser} --app="https://open.spotify.com" --new-window
  '';
  desktop = makeDesktopItem {
    inherit (app) name;
    desktopName = "Spotify Browser App";
    comment = "Launch Spotify as a standalone browser application";
    icon = "spotify";
    categories = [
      "Audio"
      "Music"
      "Network"
    ];
    exec = app.name;
  };
in
symlinkJoin {
  inherit (app) name;
  paths = [
    app
    desktop
  ];
  meta.mainProgram = app.name;
}
