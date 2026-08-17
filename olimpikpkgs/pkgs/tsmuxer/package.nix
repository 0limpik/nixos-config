{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  zlib,
  freetype,
}:
stdenv.mkDerivation rec {
  pname = "tsmuxer";
  version = "2.7.2";

  src = fetchFromGitHub {
    owner = "jaminmc";
    repo = "tsMuxer";
    tag = "v${version}";
    hash = "sha256-tkahwjLwIqG2RcJI50WpRuEG/5kGw8cUkwwo5i9kc2k=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    zlib
    freetype
  ];

  cmakeFlags = [
    "-DTSMUXER_BUILD_GUI=ON"
  ];

  meta = {
    description = "tsMuxer is a transport stream muxer for remuxing/muxing elementary streams, EVO/VOB/MPG, MKV/MKA, MP4/MOV, TS, M2TS to TS to M2TS to MKV.";
    homepage = "https://github.com/jaminmc/tsMuxer";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ olimpik ];
  };
}
