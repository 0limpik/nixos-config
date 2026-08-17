{
  dolphin,
}:
dolphin.overrideAttrs (attrs: {
  patches = (attrs.patches or [ ]) ++ [
    #./add-fallback-for-reading-icon-name-from-xattrs.patch
    ./add-fallback-for-reading-icon-name-from-writable-loc.patch
  ];
})
