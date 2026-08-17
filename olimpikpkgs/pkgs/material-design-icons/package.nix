{
  lib,
  stdenvNoCC,
  fetchFromGitHub,

  parallel,
  xmlstarlet,

  colorScheme ? {
    palette = {
      accent = "#000000";
      base = "#000000";
    };
  },
}:
stdenvNoCC.mkDerivation rec {
  pname = "material-design-icons-4.0.0";
  version = "0.14.15";
  src = fetchFromGitHub {
    owner = "marella";
    repo = "material-design-icons";
    tag = "v${version}";
    hash = "sha256-x5pAsHUmERd/UuQ4TM/A1vQS1sA+aPUFUJr5zHTe7xA=";
  };
  nativeBuildInputs = [
    parallel
    xmlstarlet
  ];
  installPhase = ''
    find "$src/svg" -mindepth 2 -type f \
    | parallel --will-cite -j "$NIX_BUILD_CORES" '
      icon_path="{}"
      icon_dir_name="''${icon_path%/*}"
      icon_dir_name="''${icon_dir_name##*/}"
      icon_ext="''${icon_path##*.}"
      icon_name="''${icon_path##*/}"
      icon_name="''${icon_name%."$icon_ext"}"

      if [[ $icon_dir_name == "two-tone" ]]; then
        XMLSTARLET_ARGS=(
          -i "//svg:*[@opacity][not(@style)]" -t attr -n style -v "fill:${colorScheme.palette.base}"
          -u "//svg:*[@opacity]/@style" -v "fill:${colorScheme.palette.base}"
          -i "//svg:*[not(@opacity)][not(@style)]" -t attr -n style -v "fill:${colorScheme.palette.accent}"
          -u "//svg:*[not(@opacity)]/@style" -v "fill:${colorScheme.palette.accent}"
        )
      else
        XMLSTARLET_ARGS=(
          -i "//svg:*[not(@style)]" -t attr -n style -v "fill:${colorScheme.palette.accent}"
          -u "//svg:*/@style" -v "fill:${colorScheme.palette.accent}"
        )
      fi

      install_dir="$out/share/icons/Material-Design/scalable/emblems"
      install_name="material-design-''${icon_name}-''${icon_dir_name}.''${icon_ext}"
      install_path="$install_dir/$install_name"
      install -D -m 644 "$icon_path" "$install_path"
      xmlstarlet ed -L \
        -N svg="http://www.w3.org/2000/svg" \
        -d "/svg:svg/@width" \
        -d "/svg:svg/@height" \
        "''${XMLSTARLET_ARGS[@]}" \
        "$install_path"
    '
  '';

    meta = {
      description = "Material Design icons by Google (Material Symbols)";
      homepage = "https://developers.google.com/fonts/docs/material_icons";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ olimpik ];
    };
}
