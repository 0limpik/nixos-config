{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  x265,

  uniform-names,
}:
stdenv.mkDerivation {
  pname = "x265-encoder";
  version = "0.unstable-2024-10-29";

  src = fetchFromGitHub {
    owner = "gdaswani";
    repo = "x265_encoder";
    rev = "6b14c2ca2076b4bb2febd958afdf0dc1166279f4";
    hash = "sha256-o7fPcbHiP3aqlAE4RlBosH+/rp1nGYKgCtbqkcrz1+Q=";
  };

  patches = [
    ./fix-file-name-type.patch
  ]
  ++ lib.optional uniform-names [
    ./uniform-names.patch
  ];

  buildInputs = [
    x265
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp ./bin/x265_encoder.dvcp $out/encoder.dvcp

    runHook postInstall
  '';

  postFixup = ''
    patchelf --replace-needed libx265.so.215 ${lib.getLib x265}/lib/libx265.so.215 $out/encoder.dvcp
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--flake"
      "--override-filename"
      "./pkgs/davinci-resolve/encoders/UDaManFunks/x265-encoder/default.nix"
    ];
  };

  meta = with lib; {
    homepage = "https://github.com/gdaswani/x265_encoder";
    description = "x265 encoder plugin for DaVinci Resolve Studio using FFmpeg backend";
    maintainers = with maintainers; [ olimpik ];
    platforms = [ "x86_64-linux" ];
  };
}
