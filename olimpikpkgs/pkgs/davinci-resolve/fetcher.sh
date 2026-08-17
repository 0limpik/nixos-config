get_download_latest_url() {
  local platform="${1:?platform at first argument is required}"
  local product="${2:?product at second argument is required}"
  local version="${3:?version at third argument is required}"

  local downloads_urls
  downloads_urls="$(get_downloads_urls "$platform" "$product")" || return
  local filtered_urls
  filtered_urls="$(
    jq \
      --raw-output \
      --arg version "$version" '[
        ($version
          | split(".")
          | map(tonumber)
        ) as $v
        | .[]
        | select(
                ($v[0] == null or $v[0] == .major)
            and ($v[1] == null or $v[1] == .minor)
            and ($v[2] == null or $v[2] == .releaseNum)
            and ($v[3] == null or $v[3] == .buildNum)
            and ($v[4] == null or $v[4] == .beta)
        )]
      ' <<<"$downloads_urls"
  )" || return
  local latest_url
  latest_url="$(
    jq \
      --raw-output '
        max_by([
          .major,
          .minor,
          .releaseNum,
          .buildNum,
          .beta
        ])
      ' <<<"$filtered_urls"
  )" || return
  if [[ -z $latest_url || $latest_url == "null" ]]; then
    echo "empty latest_url in response!" >&2
    return 1
  fi
  echo "$latest_url"
}

get_archive_url() {
  local download_id="${1:?download_id at first argument is required}"
  local user_agent="${2:?user_agent at second argument is required}"
  local refferer="${3:?refferer at third argument is required}"
  local body="${4:?refferer at fourth argument is required}"

  local archive_url
  archive_url="$(
    curl \
      --silent \
      --compressed \
      --header "Host: www.blackmagicdesign.com" \
      --header "Accept: application/json, text/plain, */*" \
      --header "Origin: https://www.blackmagicdesign.com" \
      --header "$user_agent" \
      --header "Content-Type: application/json;charset=UTF-8" \
      --header "Referer: https://www.blackmagicdesign.com/support/download/$refferer/Linux" \
      --header "Accept-Encoding: gzip, deflate, br" \
      --header "Accept-Language: en-US,en;q=0.9" \
      --header "Authority: www.blackmagicdesign.com" \
      --header "Cookie: _ga=GA1.2.1849503966.1518103294; _gid=GA1.2.953840595.1518103294" \
      --data-ascii "$body" \
      "https://www.blackmagicdesign.com/api/register/us/download/$download_id"
  )" || return
  if [[ -z $archive_url ]]; then
    echo "empty archive_url response!" >&2
    return 1
  fi
  echo "$archive_url"
}

get_archive_size() {
  local url="${1:?url at first argument is required}"

  local headers
  headers="$(
    curl \
      --silent \
      --head \
      "$url"
  )" || return
  if [[ -z $headers ]]; then
    echo "empty headers response!" >&2
    return 1
  fi

  local content_length
  content_length="$(
    grep \
      --only-matching \
      --ignore-case \
      --perl-regexp \
      '^content-length:\s*\K[0-9]+' \
      <<<"$headers" |
      tr --delete '\r'
  )" || return
  if [[ -z $content_length ]]; then
    echo "missing content_length in response!" >&2
    return 1
  fi
  echo "$content_length"
}
