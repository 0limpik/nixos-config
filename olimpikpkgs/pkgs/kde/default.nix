{
  kdePackages,
}:
kdePackages.overrideScope (
  final: prev: {
    dolphin = kdePackages.callPackage ./dolphin/package.nix { };
    kio = kdePackages.callPackage ./kio/package.nix { };
  }
)
