update_scope() {
  local scope="${1:?scope at first argument is required}"

  local user_key="${scope//_/-}"
  printf '=%.0s' {1..16} >&2
  echo >&2
  echo "update: ${user_key%:*}" >&2
  echo "processes: ${user_key#*:}" >&2
  local output
  output="$(nix eval --raw ".#maintained.${user_key%:*}")" || return
  local -a packages
  read -ra packages <<<"$output"
  echo "count: ${#packages[@]}" >&2
  printf '=%.0s' {1..16} >&2
  echo >&2
  xargs \
    --max-args 1 \
    --max-procs "${user_key#*:}" \
    nix-update \
    --quiet \
    --flake \
    --use-update-script \
    <<<"${packages[@]}" || return
  rm "result"
}

