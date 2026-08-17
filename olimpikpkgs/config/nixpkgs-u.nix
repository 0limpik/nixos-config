system: pkgs:
let
  config = import ./nixpkgs.nix { inherit (pkgs) lib; };
in
import pkgs {
  inherit system;
  config = {
    allowUnfreePredicate = config.allowUnfreePredicate "u" [
      "clion-with-plugins"
      "clion"
      "ffmpeg-full"
      "amf"
      "amdenc"
      "git-fork"
      "winbox"
    ];
    overlays = [
      config.overlay
    ];
    packageOverrides =
      pkgs:
      let
        amdgpuVersion = "6.4.4";
        ubuntuVersion = "24.04";
      in
      {
        amdenc = pkgs.amdenc.overrideAttrs (attrs: rec {
          version = "25.10-2203192";
          src = pkgs.fetchurl {
            url = "https://repo.radeon.com/amdgpu/${amdgpuVersion}/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_${version}.${ubuntuVersion}_amd64.deb";
            hash = "sha256-jEvHZxTzN8TzZJuouYaOGw9xaRINA/zEg+56s/13ruw=";
          };
        });
        amf = pkgs.amf.overrideAttrs (attrs: rec {
          version = "1.4.37-2203192";
          src = pkgs.fetchurl {
            url = "https://repo.radeon.com/amdgpu/${amdgpuVersion}/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_${version}.${ubuntuVersion}_amd64.deb";
            hash = "sha256-pklpKaWLrcClRRaY9jJhFZLbyFXPUY9H5UpmARrgFPU=";
          };
        });
      };
  };
}
