{
  lib,
  fetchFromGitHub,
  fetchPnpmDeps,

  vencord,
  pnpm_11,
}:
let
  custom-sounds = fetchFromGitHub {
    owner = "0limpik";
    repo = "customSounds";
    rev = "hard-replace-datastore-to-store";
    hash = "sha256-46spKCI7N7fPPpJAZIlenHbRVhV/QYypXqoGvTivNzE=";
  };
in
vencord.overrideAttrs (
  finalAttrs: attrs: rec {
    version = "1.15.4";

    src = attrs.src.override {
      hash = "sha256-GSCTNw4J6tiQ5rB6QURi0FLKzCkmzCJfPWEeGy1yfxQ=";
    };

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs)
        pname
        src
        patches
        postPatch
        ;
      pnpm = pnpm_11;
      fetcherVersion = 4;
      hash = "sha256-Zn6No8EyGHUR36Av1VxGWD19tUMBxSUo3QPCPXzlx0U=";
    };

    postPatch = (attrs.postPatch or "") + ''
      mkdir --parents "./src/userplugins"
      cp --recursive "${custom-sounds}" "./src/userplugins/customSounds"
    '';

    passthru = attrs.passthru // {
      updateScript = attrs.passthru.updateScript.overrideAttrs (attrs: {
        text =
          builtins.replaceStrings
            [ ''exec nix-update --version "$latestTag" "$@"'' ]
            [ ''exec nix-update --version "$latestTag" --flake "$@"'' ]
            attrs.text;
      });
    };

    meta = attrs.meta // {
      maintainers = attrs.meta.maintainers ++ (with lib.maintainers; [ olimpik ]);
    };
  }
)
