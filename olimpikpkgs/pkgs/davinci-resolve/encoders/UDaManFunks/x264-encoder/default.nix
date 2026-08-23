{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  x264,

  uniform-names,
}:
stdenv.mkDerivation {
  pname = "x264-encoder";
  version = "0-unstable-2025-05-14";

  src = fetchFromGitHub {
    owner = "gdaswani";
    repo = "x264_encoder";
    rev = "e0f6d6dadcf4c31625e8956c41db41f2447beaf2";
    hash = "sha256-DJl/yVzGmPUYxI+jZ5YdoTtyW21BJEzFR9s8bdfdJIU=";
  };

  patches = lib.optional uniform-names [
    ./uniform-names.patch
  ];

  buildInputs = [
    x264
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp ./bin/x264_encoder.dvcp $out/encoder.dvcp

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--flake"
      "--override-filename"
      "./pkgs/davinci-resolve/encoders/UDaManFunks/x264-encoder/default.nix"
    ];
  };

  meta = with lib; {
    homepage = "https://github.com/gdaswani/x264_encoder";
    description = "x264 encoder plugin for DaVinci Resolve Studio using FFmpeg backend";
    maintainers = with maintainers; [ olimpik ];
    platforms = [ "x86_64-linux" ];
  };
}
