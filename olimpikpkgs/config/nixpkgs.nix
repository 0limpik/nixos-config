{
  lib,
  args,
}:
{
  allowUnfreePredicate =
    name: list: pkg:
    lib.trace "${name} | u | ${(lib.getName pkg)}" (lib.elem (lib.getName pkg) list);
  allowInsecurePredicate =
    name: list: pkg:
    lib.trace "${name} | i | ${(lib.getName pkg)}" (lib.elem (lib.getName pkg) list);
  overlay =
    final: prev:
    (
      {
        lib = prev.lib // {
          maintainers = prev.lib.maintainers // {
            olimpik = {
              email = "olimpik.net@gmail.com";
              name = "Evgeniy Galyuta";
              github = "0limpik";
            };
          };
        };
      }
      // (lib.optionalAttrs ((args.nix-update-script or null) != null) {
        inherit (args) nix-update-script;
      })
    );
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
}
