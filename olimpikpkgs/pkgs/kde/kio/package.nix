{
  kio,
}:
kio.overrideAttrs (attrs: {
  patches = (attrs.patches or [ ]) ++ [
    #./add-fallback-for-reading-icon-name-from-xattrs.patch
  ];
})
