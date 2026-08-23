{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  clang,
  llvmPackages,
  pkg-config,
  fdk_aac,

  uniform-names,
}:

stdenv.mkDerivation rec {
  pname = "resolve-linux-studio-aac-fdk-encoder-plugin";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "hexitnz";
    repo = "Resolve-Linux-Studio-AAC-FDK-Encoder-plugin";
    rev = "64fe082fa1fa9b725d7f4ca22b1d76016bb3e527";
    hash = "sha256-jQszdeJfkcg7djJh5Dt5w19IlEeJTm+GciyL5RSYecM=";
  };

  patches = lib.optional uniform-names [
    ./uniform-names.patch
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    clang
    fdk_aac
    llvmPackages.libcxx
  ];

  sourceRoot = "${src.name}/src";

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp ./bin/aac_fdk_plugin.dvcp $out/encoder.dvcp

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--flake"
      "--override-filename"
      "./pkgs/davinci-resolve/encoders/hexitnz/resolve-linux-studio-aac-fdk-encoder-plugin/default.nix"
    ];
  };

  meta = with lib; {
    homepage = "https://github.com/hexitnz/Resolve-Linux-Studio-AAC-FDK-Encoder-plugin";
    description = "AAC encoder plugin for DaVinci Resolve Studio using FDK-AAC backend";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ olimpik ];
    platforms = [ "x86_64-linux" ];
  };
}
