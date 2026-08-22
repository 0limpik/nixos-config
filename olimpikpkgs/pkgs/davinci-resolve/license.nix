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
                  ${lib.getExe perl} -pi -e 's/\xBE\x05\x00\x00\x00\xE8\x0B\x8A\x01\x00\x84\xC0\x0F\x84\xCA\x00\x00\x00/\xBE\x05\x00\x00\x00\xE8\x0B\x8A\x01\x00\x84\xC0\x90\x90\x90\x90\x90\x90/' "$out/bin/resolve"
                  ${lib.getExe perl} -pi -e 's/\xB3\x01\xE8\x64\x92\x98\x03\x84\xC0\x0F\x85\xC9\x00\x00\x00/\xB3\x01\xE8\x64\x92\x98\x03\x84\xC0\x90\xE9\xC9\x00\x00\x00/' "$out/bin/resolve"
                  ${lib.getExe perl} -0777 -pi -e 's/\x74(.\xBF\x16\x00\x00\x00\xBE.\x01\x00\x00(?:\x89\xC2\x89\xC3)?\xE8)/\x75$1/g' "$out/bin/resolve"
                '';
              }
            );
        };
      }
    ));
})
