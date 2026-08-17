get_value_count() {
  local search="${1:?search at first argument is required}"
  local value="${2:-}"

  value="$(grep --fixed-strings --only-matching "$search" <<<"$value")" || return
  value="$(wc --lines <<<"$value")" || return
  echo "{$value}"
}

get_value_pretty() {
  local key="${1:?key at first argument is required}"
  local value="${2:-}"

  case "$value" in
  "true")
    value="✔"
    ;;
  "false")
    value="✗"
    ;;
  "null")
    value="∅"
    echo "$value"
    return
    ;;
  "none")
    value="–"
    echo "$value"
    return
    ;;
  /nix/store/*)
    value="${value#/nix/store/}"
    hash="${value%%-*}"
    name="${value#*-}"
    name="${name%%/*}"
    local hash_s="${hash:0:4}"
    local hash_e="${hash: -4}"
    value="${hash_s^^}·${hash_e^^} $name"
    ;;
  \{*)
    value="{ $(wc --lines <<<"$value") }"
    ;;
  *)
    case "$key" in
    "wm.niri.startups" | "wm.niri.run-visible")
      value="$(get_value_count "spawn-at-startup" "$value")" || return
      ;;
    "wm.niri.workspaces")
      value="$(get_value_count "workspace" "$value")" || return
      ;;
    "wm.niri.themes")
      if [[ $value != "null" ]]; then
        value="+"
      fi
      ;;
    "wm.niri.windows")
      value="$(get_value_count "window-rule" "$value")" || return
      ;;
    esac
    ;;
  esac

  echo "$value"
}

generate() {
  local location="${1:?location at first argument is required}"

  printf '%s\n' \
    "|          | nixos       |              | home-manager |              |" \
    "| -------- | ----------- | ------------ | ------------ | ------------ |" \
    "| **name** | **MS-7B85** | **G1619-04** | **MS-7B85**  | **G1619-04** |" \
    >>"$location"

  sources=(
    "os_pc_main"
    "os_pc_mini"
    "hm_pc_main"
    "hm_pc_mini"
  )

  local nix_eval
  for source in "${sources[@]}"; do
    local "$source"
    local eval="" attr="${source#*_}"
    attr="${attr//_/-}"
    if [[ ${source%%_*} == "os" ]]; then
      eval="$source = getOrEmpty x.${attr}.options.my.{};"
    fi
    if [[ ${source%%_*} == "hm" ]]; then
      eval="$source = getOrEmpty x.${attr}.options.home-manager.users.valueMeta.attrs.olimpik.configuration.options.my.{};"
    fi
    nix_eval=''"$nix_eval"'
      '"$eval"''
  done

  local output
  output="$(nix eval --json .#nixosConfigurations.pc-main.options.my)" || return
  local lines
  lines="$(jq -r 'paths(scalars) | join(".")' <<<"$output")" || return
  local -a keys
  mapfile -t keys <<<"$lines"
  for key in "${keys[@]}"; do
    local values=""
    values="$(nix eval --json ".#nixosConfigurations" \
      --apply 'x:
      let
        getOrEmpty = option:
          let
            result = builtins.tryEval option.value;
          in
            if result.success
            then { 
              value = result.value;
              loc = if option.definitionsWithLocations == []
                then "null"
                else (builtins.head option.definitionsWithLocations).file;
            }
            else {
              value = "none";
              loc = null;
            };
      in {
        '"${nix_eval//\{\}/$key}"'
      }')" || return

    local line="| $key |"
    for source in "${sources[@]}"; do
      local option="" value="" loc=""
      option="$(jq --raw-output '.'"$source"'' <<<"$values")" || return
      value="$(jq --raw-output '.value' <<<"$option")" || return
      loc="$(jq --raw-output '.loc' <<<"$option")" || return
      loc=${loc#/nix/store/}
      loc=${loc#*/}
      value="$(get_value_pretty "$key" "$value")" || return
      if [[ $loc != "null" ]]; then
        line=''"$line [$value]($loc) |"
      else
        line=''"$line $value |"
      fi
    done
    printf '%s\n' \
      "$line" \
      >>"$location"
  done
}
