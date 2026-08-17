{
  lib,
  fetchFromGitHub,
  vesktop,
  vencord,
  electron_43,
}:
vesktop.override {
  electron_43 = electron_43;
  vencord =
    let
      custom-sounds = fetchFromGitHub {
        owner = "0limpik";
        repo = "customSounds";
        rev = "hard-replace-datastore-to-store";
        hash = "sha256-46spKCI7N7fPPpJAZIlenHbRVhV/QYypXqoGvTivNzE=";
      };
    in
    vencord.overrideAttrs (attrs: rec {
      version = "1.15.1";
      src = attrs.src.override {
        hash = "sha256-QwJoc49N0F03w7FvOcFJDmpv+qVO6PwX+o5ZFx1KrUo=";
      };
      postPatch = (attrs.postPatch or "") + ''
        mkdir --parents "./src/userplugins"
        cp --recursive "${custom-sounds}" "./src/userplugins/customSounds"
      '';
    });
  withSystemVencord = true;
}
