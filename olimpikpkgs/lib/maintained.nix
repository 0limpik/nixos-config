{
  lib,
  pkgs,
}:
let
  hasOlimpik = maintainer: (maintainer.github or "") == "0limpik";
in
{
  packages =
    let
      packageNames = lib.attrNames (
        lib.filterAttrs (
          _: drv:
          if !lib.isDerivation drv || drv.meta == null then
            false
          else
            lib.any hasOlimpik (drv.meta.maintainers or [ ])
        ) pkgs
      );
    in
    lib.concatStringsSep " " packageNames;
  vscode-extensions =
    let
      vscodeExtensionsNames = lib.filter (n: n != null) (
        lib.flatten (
          lib.mapAttrsToList
            (
              publisher: extensions:
              lib.mapAttrsToList (
                extension: drv:
                if lib.any hasOlimpik (drv.meta.maintainers or [ ]) then
                  "vscode-extensions.${publisher}.${extension}"
                else
                  null
              ) extensions
            )
            (
              lib.removeAttrs pkgs.vscode-extensions [
                "override"
                "overrideDerivation"
              ]
            )
        )
      );
    in
    lib.concatStringsSep " " vscodeExtensionsNames;
  davinci-resolve-encoders =
    let
      packageNames = lib.map (name: "davinci-resolve-encoders.${name}") (
        lib.attrNames (
          lib.filterAttrs (
            name: value:
            if !lib.isDerivation value || value.meta == null then
              false
            else
              lib.any hasOlimpik (value.meta.maintainers or [ ])
          ) pkgs.davinci-resolve-encoders
        )
      );
    in
    lib.concatStringsSep " " packageNames;
}
