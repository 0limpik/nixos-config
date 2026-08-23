{
  lib,
  fetchFromGitHub,
  fetchPnpmDeps,
  
  vesktop,
  vencord,
  electron_43,
  pnpm_11,
  nix-update-script,
}:
(vesktop.override {
  inherit electron_43 vencord;
  withSystemVencord = true;
}).overrideAttrs
  (
    finalAttrs: attrs: rec {
      version = "1.6.7";

      src = attrs.src.override {
        hash = "sha256-Y74FIqcY26Dizz+DoY+r8caOfX+4/VmiEbmhcOpMHqE=";
      };

      pnpmDeps = fetchPnpmDeps {
        inherit (finalAttrs)
          pname
          version
          src
          patches
          ;
        pnpm = pnpm_11;
        fetcherVersion = 4;
        hash = "sha256-AK+ZbylpG7iKWKsIA0nfFfZYP7HaTCTSeDbNUFx/iY4=";
      };

      passthru = attrs.passthru // {
        updateScript = nix-update-script {
          extraArgs = [ "--flake" ];
        };
      };

      meta = attrs.meta // {
        maintainers = attrs.meta.maintainers ++ (with lib.maintainers; [ olimpik ]);
      };
    }
  )
