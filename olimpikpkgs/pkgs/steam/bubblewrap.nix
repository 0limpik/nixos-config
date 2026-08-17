{
  bubblewrap,
}:
bubblewrap.overrideAttrs (attrs: {
  name = "${attrs.pname}-${attrs.version}-SteamVR";
  patches = (attrs.patches or [ ]) ++ [
    ./bubblewrap__steam-vr.patch
  ];
})
