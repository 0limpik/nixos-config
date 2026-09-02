{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "elio";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FT5F3L8IgbX6vPjEd+TSudoyIZe4TX7no0FF9C75aaU=";
  };

  cargoHash = "sha256-gnUPukVYevg6JpPIVqDt/9LMtb3FmC8NNgJH6AU8fBE=";

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
