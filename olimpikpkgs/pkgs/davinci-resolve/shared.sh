get_downloads_json() {
  local json
  json="$(
    curl \
      --silent \
      --compressed \
      "https://www.blackmagicdesign.com/api/support/us/downloads.json"
  )" || return
  if [[ -z $json ]]; then
    echo "empty json response!" >&2
    return 1
  fi
  echo "$json"
}

get_downloads_urls() {
  local platform="${1:?platform at first argument is required}"
  local product="${2:?product at second argument is required}"

  local json
  json="$(get_downloads_json)" || return
  local downloads
  downloads="$(
    jq \
      --arg platform "$platform" \
      --arg product "$product" \
      --raw-output '[
          .downloads[] 
          | select(
            .urls[$platform]
          )
          | .urls[$platform][]
          | select(.product | test($product))]
      ' <<<"$json"
  )" || return
  echo "$downloads"
}
