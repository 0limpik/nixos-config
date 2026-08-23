{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  clang,
  ffmpeg,

  uniform-names,
}:
stdenv.mkDerivation rec {
  pname = "davinci-linux-aac-codec";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "Toxblh";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-NVNxmUFNwZ3hzlyi3QVENXhfPICAAP3M4s6QEgWsP/g=";
  };

  patches = [
    ./change-plugin-uuid.patch
  ]
  ++ lib.optional uniform-names [
    ./uniform-names.patch
  ];

  buildInputs = [
    clang
    ffmpeg
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp ./bin/aac_encoder_plugin.dvcp $out/encoder.dvcp

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--override-filename"
      "./pkgs/davinci-resolve/encoders/nowrep/dvcp-vaapi/default.nix"
    ];
  };

  meta = with lib; {
    homepage = "https://github.com/Toxblh/davinci-linux-aac-codec";
    description = "AAC encoder plugin for DaVinci Resolve Studio using FFmpeg backend";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ olimpik ];
    platforms = [ "x86_64-linux" ];
  };
}
