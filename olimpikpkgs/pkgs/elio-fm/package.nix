{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "elio";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6A/VxmRl/YpaaaMrlw3UExdKRn3yh8SVazD8ee1HETE=";
  };

  cargoHash = "sha256-6hiXp3LvKToifGkYN22H/GRSClNQ6a64cEWjqPKMhfw=";

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
