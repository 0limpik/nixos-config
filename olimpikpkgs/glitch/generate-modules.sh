generate() {
  local location="${1:?location at first argument is required}"

  printf '%s\n' \
    "| name | type | default |" \
    "| ---- | ---- | ------- |" \
    >>"$location"

  local loc_cut="${location%/*}"
  loc_cut="${loc_cut#./*}"

  local output
  output="$(nix eval --json .#nixosConfigurations.pc-main.options.my)" || return
  local lines
  lines="$(jq --raw-output 'paths(scalars) | join(".")' <<<"$output")" || return
  local -a keys
  mapfile -t keys <<<"$lines"
  for key in "${keys[@]}"; do
    local option=""
    option="$(nix eval --json ".#nixosConfigurations.pc-main.options.my.$key" \
      --apply 'x: {
        type = x.type.name;
        default = x.default or "";
        loc = builtins.head x.declarations;
      }')" || return
    local type="" default="" loc=""
    type="$(jq --raw-output '.type' <<<"$option")" || return
    default="$(jq --raw-output '.default' <<<"$option")" || return
    loc="$(jq --raw-output '.loc' <<<"$option")" || return
    loc="${loc#/nix/store/}"
    loc="${loc#*/}"
    loc="${loc#"$loc_cut"/*}"

    printf '%s\n' \
      "| [$key]($loc) | [$type](https://nixos.org/manual/nixos/stable/#sec-option-types) | $default |" \
      >>"$location"
  done
}
