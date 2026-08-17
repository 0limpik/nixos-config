get_latest_version() {
  local platform="${1:?platform at first argument is required}"
  local product="${2:?product at second argument is required}"

  local downloads_urls
  downloads_urls="$(get_downloads_urls "$platform" "$product")" || return
  local latest_version
  latest_version="$(
    jq \
      --raw-output '
        max_by([
          .major,
          .minor,
          .releaseNum,
          .buildNum,
          .beta
        ])
        | "\(.major).\(.minor).\(.releaseNum)"
      ' <<<"$downloads_urls "
  )" || return 1
  if [[ -z $latest_version || $latest_version == "null" ]]; then
    echo "empty latest_version in response!" >&2
    return 1
  fi
  echo "$latest_version"
}
