{
  lib,
  stdenv,
  fetchFromGitHub,

  meson,
  ninja,
  pkg-config,
  libdrm,
  libva,
  ffmpeg,
  xz,
  lame,
  libtheora,
  xvidcore,
  soxr,
  libvdpau,
  openapv,

  uniform-names,
}:
stdenv.mkDerivation rec {
  pname = "dvcp-vaapi";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "nowrep";
    repo = "dvcp-vaapi";
    tag = "v${version}";
    hash = "sha256-khy4H39okawhDM+MygIf+FIxKToKINg9XZFCF/MRq7Y=";
  };

  patches = [
    ./remove-ffmpeg-subproject.patch
  ]
  ++ lib.optional uniform-names [
    ./uniform-names.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    ffmpeg
    libdrm
    libva
    xz
    lame
    libtheora
    xvidcore
    soxr
    libvdpau
    openapv
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp ./vaapi_encoder.dvcp $out/encoder.dvcp

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/nowrep/dvcp-vaapi";
    description = "VAAPI encoder plugin for DaVinci Resolve Studio using FFmpeg backend";
    license = licenses.mit;
    maintainers = with maintainers; [ olimpik ];
    platforms = [ "x86_64-linux" ];
  };
}
