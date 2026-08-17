{
  makeDesktopItem,
  writeShellScriptBin,
  symlinkJoin,

  run,
}:
let
  app = writeShellScriptBin "nixos-editor" ''
    exec ${run}
  '';
  desktop = makeDesktopItem {
    inherit (app) name;
    desktopName = "NixOS";
    comment = "Launch NixOS cofiguration in editor";
    icon = "nixos-stable";
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
