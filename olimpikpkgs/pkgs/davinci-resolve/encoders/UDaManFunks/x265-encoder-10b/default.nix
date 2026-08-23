{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  x265,

  uniform-names,
}:
stdenv.mkDerivation rec {
  pname = "x265-encoder-10b";
  version = "0-unstable-2024-08-21";

  src = fetchFromGitHub {
    owner = "gdaswani";
    repo = "x265_encoder_10b";
    rev = "2c02dd024fe2224aab12dd301ab0e6b542489bb1";
    hash = "sha256-CB2yQKz1n5HLGtub1jmNIhiS22mBsDNmxz5EVy0Iktc=";
  };

  patches = [
    ./fix-file-name-type.patch
  ]
  ++ lib.optional uniform-names [
    ./uniform-names.patch
  ];

  x265-high-bit-depth = (
    x265.overrideAttrs (old: {
      preConfigure =
        builtins.replaceStrings [ "-DHIGH_BIT_DEPTH:BOOL=FALSE" ] [ "-DHIGH_BIT_DEPTH:BOOL=TRUE" ]
          old.preConfigure;
    })
  );

  buildInputs = [
    x265-high-bit-depth
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp ./bin/x265_encoder_10b.dvcp $out/encoder.dvcp

    runHook postInstall
  '';

  postFixup = ''
    patchelf --replace-needed libx265.so.215 ${lib.getLib x265-high-bit-depth}/lib/libx265.so.215 $out/encoder.dvcp
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--flake"
      "--override-filename"
      "./pkgs/davinci-resolve/encoders/UDaManFunks/x265-encoder-10b/default.nix"
    ];
  };

  meta = with lib; {
    homepage = "https://github.com/gdaswani/x265_encoder_10b";
    description = "x265 10-bit encoder plugin for DaVinci Resolve Studio using FFmpeg backend";
    maintainers = with maintainers; [ olimpik ];
    platforms = [ "x86_64-linux" ];
  };
}
