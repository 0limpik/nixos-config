{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  ffmpeg,

  uniform-names,
}:
stdenv.mkDerivation {
  pname = "prores-encoder";
  version = "0-unstable-2024-08-21";

  src = fetchFromGitHub {
    owner = "gdaswani";
    repo = "prores_encoder";
    rev = "6a30b9c43506764734d1d79313fa2576ed7836bf";
    hash = "sha256-RgXeiVbgzsybWaPVtVhBpx61UcvF10T91trjBV1lVLg=";
  };

  patches = lib.optional uniform-names [
    ./uniform-names.patch
  ];

  buildInputs = [
    ffmpeg
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp ./bin/prores_encoder.dvcp $out/encoder.dvcp

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--flake"
      "--override-filename"
      "./pkgs/davinci-resolve/encoders/UDaManFunks/prores-encoder/default.nix"
    ];
  };

  meta = with lib; {
    homepage = "https://github.com/gdaswani/prores_encoder";
    description = "ProRes encoder plugin for DaVinci Resolve Studio using FFmpeg backend";
    maintainers = with maintainers; [ olimpik ];
    platforms = [ "x86_64-linux" ];
  };
}
