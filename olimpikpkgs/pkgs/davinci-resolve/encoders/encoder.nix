{
  runCommandLocal,
}:
{
  name ? null,
  pname ? null,
  version ? null,
  encoder-name ? pname,
  dvcp,
}:
let
  original-name =
    if (name == null) then if (version == null) then "${pname}-${version}" else pname else name;
in
runCommandLocal "davinci-resolve-encoder-${original-name}"
  {
    inherit pname version;
    inherit (dvcp) src passthru meta;
  }
  /* bash */ ''
    if [[ ! -f "${dvcp}/encoder.dvcp" ]]; then
      echo "${dvcp}/encoder.dvcp does not exist!" >&2
      exit 1
    fi
    dir="$out/${encoder-name}.dvcp.bundle/Contents/Linux-x86-64"
    mkdir --parents "$dir"
    ln --symbolic "${dvcp}/encoder.dvcp" "$dir/${encoder-name}.dvcp"
  ''
