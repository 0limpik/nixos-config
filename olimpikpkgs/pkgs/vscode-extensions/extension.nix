{
  lib,
  fetchurl,
  stdenvNoCC,
  writeShellApplication,
  curl,
  nix,
  file,
  gzip,
  unzip,
  xmlstarlet,
  common-updater-scripts,
  coreutils,
  diffutils,
  git,
  gnugrep,
  gnused,
  jq,
  makeWrapper,
}:
{
  publisher,
  name,
  version,
  hash,
  location,
}:
stdenvNoCC.mkDerivation {
  pname = "vscode-extension-${publisher}-${name}";
  inherit version;
  vscodeExtPublisher = publisher;
  vscodeExtName = name;
  vscodeExtUniqueId = "${publisher}.${name}";
  src = fetchurl {
    url =
      "https://marketplace.visualstudio.com/_apis/public/gallery/publishers"
      + "/${publisher}/vsextensions/${name}/${version}/vspackage";
    inherit hash;
  };
  nativeBuildInputs = [
    file
    unzip
    gzip
  ];
  unpackPhase = /* bash */ ''
    archive_type="$(file \
      --brief \
      --mime-type \
      "$src"
    )"
    if [[ "$archive_type" == "application/gzip" || "$archive_type" == "application/x-gzip" ]]; then
      archive_vsix_path="./extension.vsix"
      gunzip < "$src" > "$archive_vsix_path"
      unzip -d "./" "$archive_vsix_path"
    else
      unzip -d "./" "$src"
    fi
  '';
  install_prefix = "share/vscode/extensions/${publisher}.${name}";
  installPhase = /* bash */ ''
    mkdir --parents "$out/$install_prefix";
    cp --recursive "./extension/." "$out/$install_prefix"/
  '';
  passthru = {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-vscode-extension";
      runtimeInputs = [
        curl
        nix
        unzip
      ];
      text = /* bash */ ''
        if ! [[ "$UPDATE_NIX_ATTR_PATH" =~ ^([^\.]*)\.([^\.]*)\.([^\.]*)$ ]]; then
          echo "can't parse attr_path!
            $UPDATE_NIX_ATTR_PATH" >&2
          exit 1
        fi

        #shellcheck disable=SC2034
        scope="''${BASH_REMATCH[1]}"
        publisher="''${BASH_REMATCH[2]}"
        name="''${BASH_REMATCH[3]}"

        "${./update}" \
          --publisher "$publisher" \
          --name "$name" \
          --version "$UPDATE_NIX_OLD_VERSION" \
          --location "${location}" \
          --user-agent "curl/${curl.version} Nixpkgs/${lib.version}"
      '';
    });
  };
  meta.maintainers = with lib.maintainers; [ olimpik ];
}
