{
  lib,
  stdenv,
  fetchFromGitHub,

  ffmpeg_4,
  zlib,

  uniform-names,
}:

stdenv.mkDerivation rec {
  pname = "resolve-prores";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "jonny9f";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-nKU+0ks9d1oUDm6E2VR39q/euRWz3nwSDcI0Q4CuKCQ=";
  };

  patches = [
    ./change-plugin-uuid.patch
    #./fixes-ffmpeg8.patch
  ]
  ++ lib.optional uniform-names [
    ./uniform-names.patch
  ];

  buildInputs = [
    ffmpeg_4
    zlib
  ];

  sourceRoot = "${src.name}/prores_encoder_plugin";

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp ./bin/prores_encoder_plugin.dvcp $out/encoder.dvcp

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/jonny9f/resolve-prores";
    description = "ProRes encoder plugin for DaVinci Resolve Studio using FFmpeg 4 backend";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ olimpik ];
    platforms = [ "x86_64-linux" ];
  };
}
