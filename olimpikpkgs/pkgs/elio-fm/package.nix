{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "elio";
  version = "1.11.2";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-k+88cWiHi1a+f6oulb5MTCnWrJU4vKPEAHBwq5H9bkQ=";
  };

  cargoHash = "sha256-JxdWxkpyYbNxe7B1WNKRDyj2xH1W2kQn2rYj/NdPkY4=";

  postPatch = ''
    substituteInPlace "./src/app/overlays/inline_image/protocol.rs" \
      --replace-fail \
        'TerminalIdentity::Alacritty | TerminalIdentity::Other => ImageProtocol::None,' \
        'TerminalIdentity::Alacritty => ImageProtocol::Sixel,TerminalIdentity::Other => ImageProtocol::None,'
  '';

  doCheck = false;

  meta = {
    description = "Terminal file manager with rich previews, inline images, and trash support";
    homepage = "https://elio-fm.github.io";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ olimpik ];
    mainProgram = "elio";
  };
})
