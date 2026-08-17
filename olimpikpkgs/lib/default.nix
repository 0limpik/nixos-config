{
  lib,
  source,
  path,
}:
let
  isSystem = source == "system";
  isHome = source == "home";
  isAny = isSystem || isHome;
in
rec {
  mkIf = condition: content: lib.mkIf condition (mkConfig content);
  mkConfig =
    config:
    let
      unknown = builtins.filter (
        name:
        !(builtins.elem name [
          "os"
          "hm"
          "any"
        ])
      ) (builtins.attrNames config);
    in
    if unknown != [ ] then
      throw "o: unknown config properties: ${builtins.concatStringsSep ", " unknown}"
    else if config == [ ] then
      throw "o: empty config"
    else
      lib.mkMerge [
        (lib.optionalAttrs isSystem (config.os or { }))
        (lib.optionalAttrs isHome (config.hm or { }))
        (lib.optionalAttrs isAny (config.any or { }))
      ];
  user = user: path + /assets/${user};
  local = config: user config.home.username;
  static = config: "${config.home.homeDirectory}/NixOS/assets/${config.home.username}";
  mkOutOfStoreSymlink = config: config.lib.file.mkOutOfStoreSymlink;
  mkSymlink = config: path: mkOutOfStoreSymlink config "${static config}/${path}";
}
