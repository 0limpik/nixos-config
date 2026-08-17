{
  callPackage,
  mission-center,
}:
mission-center.overrideAttrs (attrs: {
  passthru = attrs.passthru or { } // {
    run = callPackage ./run.nix { };
  };
})
