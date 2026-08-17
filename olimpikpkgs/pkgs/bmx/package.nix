{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  autoPatchelfHook,
  expat,
  uriparser,
  cmake,
  pkg-config,
  util-linux,
  git,
}:
stdenv.mkDerivation rec {
  pname = "bmx";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "ebu";
    repo = "bmx";
    tag = "v${version}";
    hash = "sha256-uZwE98Zs9XeUb90sGqiIkBKyrX9D9oqUsE+bHd6tE9s=";
  };

  cmake-git-version-tracking = stdenv.mkDerivation {
    pname = "cmake-git-version-tracking";
    version = "${pname}-${version}";

    src = fetchFromGitHub {
      owner = "andrew-hardin";
      repo = "cmake-git-version-tracking";
      rev = "904dbda1336ba4b9a1415a68d5f203f576b696bb";
      sha256 = "sha256-D+slbnfkBSiO+RGCvGZxgQxWzGHd+caiKbXNb4Lu710=";
    };

    patches = [
      (fetchpatch2 {
        url = "https://github.com/ebu/bmx/raw/v${version}/cmake/git_version_904dbda.patch";
        hash = "sha256-sjOnfUj4mzZ+rKlCBY48lrJ+w6nRlyUGnx/iNDijHXo=";
      })
    ];

    installPhase = ''
      mkdir -p "$out"
      cp -r "." "$out"
    '';
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    autoPatchelfHook
    git
  ];

  buildInputs = [
    util-linux
    expat
    uriparser
  ];

  postPatch = ''
    for DEPS_PATH in "." "libMXF/deps" "libMXFpp/deps"; do
      DEPS_CMAKE_PATH="./deps/$DEPS_PATH/cmake-git-version-tracking"
      mkdir -p "$DEPS_CMAKE_PATH"
      cp -r "${cmake-git-version-tracking}/." "$DEPS_CMAKE_PATH"
    done

    substituteInPlace "./bmx.pc.in" "./deps/libMXF/libMXF.pc.in" "./deps/libMXFpp/libMXF++.pc.in" \
      --replace-fail "\''${prefix}/@CMAKE_INSTALL_INCLUDEDIR@" "@CMAKE_INSTALL_FULL_INCLUDEDIR@" \
      --replace-fail "\''${prefix}/@CMAKE_INSTALL_LIBDIR@" "@CMAKE_INSTALL_FULL_LIBDIR@"
  '';

  meta = {
    description = "Library and utilities to read and write broadcasting media files. Primarily supports the MXF file format";
    homepage = "https://github.com/ebu/bmx";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ olimpik ];
  };
}
