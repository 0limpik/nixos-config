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
  custom-stream = fetchFromGitHub {
    owner = "MrTopQ";
    repo = "customStream-Vencord";
    rev = "main";
    hash = "sha256-XV4GWpXS74QUbMTmw88Zsoh26yKD03hXw3hum8uD/jk=";
  };
in
vencord.overrideAttrs (
  finalAttrs: attrs: rec {
    version = "1.15.11";

    src = attrs.src.override {
      hash = "sha256-bUbzsfrrOd7uWf1q51EohRelG9jfAoFY20gqcQ+enoE=";
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
      hash = "sha256-LiAcWwGmZlpO+rr0tcMNpViBiBRhSHj+wvyHFIe32lw=";
    };

    postPatch = (attrs.postPatch or "") + ''
      mkdir --parents "src/userplugins"
      cp --recursive "${custom-sounds}" "src/userplugins/customSounds"
      cp --recursive "${custom-stream}" "src/userplugins/customStream"
      substituteInPlace "src/userplugins/customStream/index.tsx" \
        --replace-fail 'const targetWidth = 1280;' 'const targetWidth = 1080;' \
        --replace-fail 'const targetHeight = 720;' 'const targetHeight = 921;'
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
