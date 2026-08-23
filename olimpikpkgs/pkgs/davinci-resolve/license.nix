{
  path,

  lib,
  stdenvNoCC,
  callPackage,
  perl,
}:
(callPackage path {
  callPackage =
    path: args:
    (callPackage path (
      args
      // {
        stdenvNoCC = stdenvNoCC // {
          mkDerivation =
            super:
            stdenvNoCC.mkDerivation (
              super
              // rec {
                preFixup = ''
                  ${lib.getExe perl} -pi -e 's/\x03\x00\x89\x45\xFC\x83\x7D\xFC\x00\x74\x11\x48\x8B\x45\xC8\x8B/\x03\x00\x89\x45\xFC\x83\x7D\xFC\x00\xEB\x11\x48\x8B\x45\xC8\x8B/g' "$out/bin/resolve"
                  ${lib.getExe perl} -pi -e 's/\x74\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00\x00/\xEB\x11\x48\x8B\x45\xC8\x8B\x55\xFC\x89\x50\x58\xB8\x00\x00\x00/g' "$out/bin/resolve"
                  ${lib.getExe perl} -0777 -pi -e 's/(\x40\x84\xED)\x74(.\xBF\x16\x00\x00\x00\xBE.\x01\x00\x00\xE8)/$1\x75$2/g' "$out/bin/resolve"
                '';
              }
            );
        };
      }
    ));
})
