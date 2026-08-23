{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  cmake,
  ffmpeg,

  uniform-names,
}:
stdenv.mkDerivation rec {
  pname = "ffmpeg-encoder-plugin";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "EdvinNilsson";
    repo = "ffmpeg_encoder_plugin";
    tag = "v${version}";
    hash = "sha256-F4Q8YCXD5UldTwLbWK4nHacNPQ/B+4yLL96sq7xZurM=";
  };

  patches = lib.optional uniform-names [
    ./uniform-names.patch
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    ffmpeg
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp ./ffmpeg_encoder_plugin.dvcp $out/encoder.dvcp

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--override-filename"
      "./pkgs/davinci-resolve/encoders/EdvinNilsson/ffmpeg-encoder-plugin/default.nix"
    ];
  };

  meta = with lib; {
    homepage = "https://github.com/EdvinNilsson/ffmpeg_encoder_plugin";
    description = "H.264, H.265, AV1 encoder plugin for DaVinci Resolve Studio using FFmpeg backend";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ olimpik ];
    platforms = [ "x86_64-linux" ];
  };
}
