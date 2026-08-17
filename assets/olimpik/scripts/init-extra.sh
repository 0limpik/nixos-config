my_get_github_latest_tag() {
  local owner="${1:?owner at first argument is required}"
  local repository="${2:?repository at second argument is required}"

  local json
  json="$(
    curl \
      --silent \
      --fail \
      "https://api.github.com/repos/$owner/$repository/releases/latest"
  )" || return
  if [[ -z $json ]]; then
    echo "empty json!" >&2
    return 1
  fi
  local tag_name
  tag_name="$(jq --raw-output ".tag_name" <<<"$json")" || return
  if [[ -z $tag_name || $tag_name == "null" ]]; then
    echo "empty tag_name! $json" >&2
    return 1
  fi
  echo "$tag_name"
}

my_update_flake_input_tag() {
  local url="${1:?url at first argument is required}"
  local path="${2:?path at second argument is required}"

  if ! [[ $url =~ ^([^:]*):([^\/]*)\/([^\/]*)\/(.*)$ ]]; then
    echo "can't parse url!
      $url" >&2
    return 1
  fi

  local source="${BASH_REMATCH[1]}"
  local owner="${BASH_REMATCH[2]}"
  local repository="${BASH_REMATCH[3]}"
  local current_tag="${BASH_REMATCH[4]}"

  local latest_tag
  if [[ $source == "github" ]]; then
    latest_tag="$(my_get_github_latest_tag "$owner" "$repository")" || return
  fi

  sed \
    --in-place \
    --expression "s#\($source:$owner/$repository/\)$current_tag#\1$latest_tag#" \
    "$path"
}

my_update_flake() {
  local path="${1:?path at first argument is required}"

  local urls
  urls="$(
    grep \
      --perl-regexp \
      --only-matching \
      '(?<=")[^"]*(?=";.*#.* auto_update_tag)' \
      "$path"
  )"
  for url in $urls; do
    my_update_flake_input_tag "$url" "$path" || return
  done
}

my_nixos_update() (
  local path="${1:?path at first argument is required}"

  cd "$path" || return
  my_update_flake "flake.nix" || return
  nix flake update --flake "." || return

  (
    cd "./olimpikpkgs" || return
    nix flake update --flake "." || return
    ./update || return
    rm --force "result"
  ) || return
)
