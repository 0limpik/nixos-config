{
  lib,
  runCommand,

  xmlstarlet,
  imagemagick,

  colorScheme ? {
    palette = { };
  },
  icons ? "",
}:
runCommand "local-icons"
  {
    inherit icons;
    nativeBuildInputs = [
      xmlstarlet
      imagemagick
    ];
  }
  ''
    XMLSTARLET_ARGS=(
      ${builtins.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: ''
          -u "//svg:*[@fill='#theme-${name}']/@fill" \
            -v "${value}"
          -u "//svg:*[contains(@style, 'fill:#theme-${name}')]/@style" \
            -x "concat(substring-before(., 'fill:#theme-${name}'), 'fill:${value}', substring-after(., 'fill:#theme-${name}'))"
        '') colorScheme.palette
      )}
    )

    install_dir="$out/share/icons/Local"
    for icon_dir in "$icons"/*; do
      icon_context="''${icon_dir##*/}"
      for icon_path in "$icon_dir"/*.*; do
        icon_ext="''${icon_path##*.}"
        icon_name="''${icon_path##*/}"
        icon_name="''${icon_name%."$icon_ext"}"
        icon_place="$icon_context/$icon_name.$icon_ext"
        if [[ $icon_ext == "svg" ]]; then
          install_path="$install_dir/scalable/$icon_place"
          install -D -m 644 "$icon_path" "$install_path"
          xmlstarlet ed -L \
            -N svg="http://www.w3.org/2000/svg" \
            -d "/svg:svg/@width" \
            -d "/svg:svg/@height" \
            "''${XMLSTARLET_ARGS[@]}" \
            "$install_path"
        else
          for icon_size in "16x16" "18x18" "22x22" "24x24" "32x32" "48x48" "64x64" "84x84" "96x96" "128x128"; do
            install_path="$install_dir/$icon_size/$icon_place"
            mkdir --parents "''${install_path%/*}"
            magick "$icon_path" -resize "$icon_size" "$install_path"
          done
        fi
      done
    done
  ''
