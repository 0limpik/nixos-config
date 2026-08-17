{
  lib,
  runCommand,
  fetchFromGitHub,

  catppuccin-papirus-folders,
  papirus-icon-theme,
  parallel,
  xmlstarlet,
  imagemagick,

  colorScheme ? {
    flavor = "mocha";
    accent = "blue";
    palette = { };
  },
  icons ? [ ],
}:
(catppuccin-papirus-folders.override {
  inherit (colorScheme) flavor accent;
  papirus-icon-theme = papirus-icon-theme.overrideAttrs (attrs: {
    version = "20260615";
    src = fetchFromGitHub {
      owner = "PapirusDevelopmentTeam";
      repo = "papirus-icon-theme";
      rev = "f202823e4721d050c87160688a33a223439b2a5f";
      hash = "sha256-KbUjHmNzaj7XKj+MOsPM6zh2JI+HfwuXvItUVAZAClk=";
    };
    installPhase =
      builtins.replaceStrings
        [
          "mv Papirus* $out/share/icons"
        ]
        [
          ''
            mv Papirus* "$out/share/icons"
            find "$out/share/icons" \
              \( -type f -o -type l \) \
              \( -name "vesktop.*" -o -name "dev.vencord.Vesktop.*" \) \
              -delete
          ''
        ]
        attrs.installPhase;
    dontFixup = true;
  });
}).overrideAttrs
  (attrs: {

    installPhase =
      builtins.replaceStrings
        [
          "cp -r --no-preserve=mode ${papirus-icon-theme}/share/icons/Papirus* $out/share/icons"
          "cp -r src/* $out/share/icons/Papirus"
        ]
        [
          /* bash */ ''
            for theme_path in "${papirus-icon-theme}/share/icons"/*; do
              theme_name="''${theme_path##*/}"
              target_dir="$out/share/icons/$theme_name"
              mkdir --parents "$target_dir"
              cp --recursive --no-preserve=mode "$theme_path"/. "$target_dir"
            done
          ''
          /* bash */ ''
            cp --recursive --force "./src"/. "$out/share/icons/Papirus"

            find "$out/share/icons" \
              \( -type f -o -type l \) \
              -path "*/places/*" \
              \( -name "folder-*" -o -name "user-*" \) \
              ! -name "folder-cat-${colorScheme.flavor}-*" ! -name "user-cat-${colorScheme.flavor}-*" \
              -delete

            for theme_path in "$out/share/icons"/*; do
              theme_test="$theme_path/48x48/places/folder.svg"
              rm --force "$theme_test"
              touch "$theme_test"
            done

            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (n: v: ''"${./link-theme}" "${v}/share/icons/${n}" "$out"'') icons
            )}
          ''
        ]
        attrs.installPhase;
  })
