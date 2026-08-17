get_updated() {
  package="${1:-}"
  version="${2:?version at second argument is required}"

  local updated=""
  local current_version=""
  if [[ $package =~ \|[[:space:]]([0-9]{4}-[0-9]{2}-[0-9]{2})[[:space:]]\|[[:space:]]([^[:space:]]*)[[:space:]]\| ]]; then
    updated="${BASH_REMATCH[1]}"
    current_version="${BASH_REMATCH[2]}"
  fi

  local lower_version=""
  if [[ -n $current_version ]]; then
    lower_version=$(printf '%s\n' "$version" "$current_version" | sort --version-sort | head --lines 1)
  fi
  if [[ -n $lower_version && $lower_version == "$current_version" && $lower_version != "$version" ]]; then
    updated="$(date '+%Y-%m-%d')"
  fi
  echo "$updated"
}

generate_packages() {
  local index="${1:?index at first argument is required}"
  local location="${2:?location at second argument is required}"
  local flake="${3:?flake at third argument is required}"

  printf '%s\n' \
    "| updated | version | pname | homepage |" \
    "| ------- | ------- | ----- | -------- |" \
    >>"$location"

  local output
  output="$(nix eval --raw "$flake#maintained.packages")" || return
  local -a packages
  read -ra packages <<<"$output"
  for key in "${packages[@]}"; do
    local user_key="${key//_/-}"
    local name="${user_key%:*}"
    local updated="" pname="" loc="" version="" homepage="" url="" json=""
    json="$(nix eval --json "$flake#$key" --apply 'x: { inherit (x) pname version meta; }')" || return
    pname="$(jq --raw-output '.pname' <<<"$json")" || return
    version="$(jq --raw-output '.version' <<<"$json")" || return
    loc="$(jq --raw-output '.meta.position' <<<"$json")" || return
    loc="${loc%:*}"
    loc="${loc##*/olimpikpkgs/}"
    url="$(jq --raw-output '.meta.homepage' <<<"$json")" || return
    homepage="${url##https://}"
    homepage="${homepage%%/*}"
    homepage="${homepage#www.}"

    package_r="${loc//./\\.}"
    local package="" updated=""
    package="$(grep --extended-regexp '\|[^\|]*\|[^\|]*\| \[[^]]*\]\('"$package_r"'\) \|' <<<"$index")"
    updated="$(get_updated "$package" "$version")" || return

    printf '%s\n' \
      "| $updated | $version | [$pname]($loc) | [$homepage]($url) |" \
      >>"$location"
  done
}

generate_vscode_extensions() {
  local index="${1:?index at first argument is required}"
  local location="${2:?location at second argument is required}"
  local flake="${3:?flake at third argument is required}"

  printf '%s\n' \
    "| updated | version | publisher | name | homepage |" \
    "| ------- | ------- | --------- | ---- | -------- |" \
    >>"$location"

  local output
  output="$(nix eval --raw "$flake#maintained.vscode-extensions")" || return
  local -a extensions
  read -ra extensions <<<"$output"
  for key in "${extensions[@]}"; do
    # shellcheck disable=SC2034
    local scope="${key%%.*}"
    local publisher="${key#*.}"
    publisher="${publisher%%.*}"
    local name="${key#*.}"
    name="${name#*.}"

    local version=""
    version="$(nix eval --raw "$flake#vscode-extensions.$publisher.$name.version")" || return
    local homepage="marketplace.visualstudio.com"
    local url="https://marketplace.visualstudio.com/items?itemName=$publisher.$name"

    local package="" updated=""
    package="$(grep --extended-regexp '\|[^\|]*\|[^\|]*\| '"$publisher"' \| '"$name"' \|' <<<"$index")"
    updated="$(get_updated "$package" "$version")" || return

    printf '%s\n' \
      "| $updated | $version | $publisher | $name | [$homepage]($url) |" \
      >>"$location"
  done
}

generate_davinci_resolve_encoders() {
  local index="${1:?index at first argument is required}"
  local location="${2:?location at second argument is required}"
  local flake="${3:?flake at third argument is required}"

  printf '%s\n' \
    "| updated | version | author | pname | uniform name | homepage |" \
    "| ------- | ------- | ------ | ----- | ------------ | -------- |" \
    >>"$location"

  local output
  output="$(nix eval --raw "$flake#maintained.davinci-resolve-encoders")" || return
  local -a encoders
  read -ra encoders <<<"$output"
  for key in "${encoders[@]}"; do
    local author="" pname="" version="" loc="" homepage="" url="" json=""
    json="$(nix eval --json "$flake#$key" --apply 'x: { inherit (x) pname version meta; }')" || return
    pname="$(jq --raw-output '.pname' <<<"$json")" || return
    version="$(jq --raw-output '.version' <<<"$json")" || return
    loc="$(jq --raw-output '.meta.position' <<<"$json")" || return
    loc="${loc%:*}"
    loc="${loc##*/olimpikpkgs/}"
    url="$(jq --raw-output '.meta.homepage' <<<"$json")" || return
    homepage="${url##https://}"
    homepage="${homepage%%/*}"
    homepage="${homepage#www.}"
    author="${loc#*/encoders/}"
    author="${author%%/*}"

    package_r="${loc//./\\.}"
    local package="" updated=""
    package="$(grep --extended-regexp '\|[^\|]*\|[^\|]*\| \[[^]]*\]\('"$package_r"'\) \|' <<<"$index")"
    updated="$(get_updated "$package" "$version")" || return

    printf '%s\n' \
      "| $updated | $version | $author | $pname | [${key#*.}]($loc) | [$homepage]($url) |" \
      >>"$location"
  done
}
