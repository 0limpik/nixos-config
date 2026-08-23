nix_update() {
  local package="${1:?package at first argument is required}"

  # fix
  # 293|   defaultNix =
  #    |   ^
  # 294|     builtins.removeAttrs result [ "__functor" ]
  # and
  # 222|       flake = import (outPath + "/flake.nix");
  local flake_path=""
  flake_path="$(nix store add-path --name olimpikpkgs ./)" || return
  nix build \
    --extra-experimental-features 'flakes nix-command' \
    --print-out-paths --impure --expr "
      with import <nixpkgs> { };
      let
        pkg = (
          let
            flake = builtins.getFlake \"${flake_path}\";
          in
          flake.packages.\${builtins.currentSystem}.\"davinci-resolve-studio\" or flake.\"davinci-resolve-studio\"
        );
      in
      (pkgs.writeScript \"updateScript\" (
        lib.escapeShellArgs (pkgs.lib.toList (pkg.updateScript.command or pkg.updateScript))
      ))
    " >/dev/null 2>&1 || return
  nix store add-path --name olimpikpkgs ./ >/dev/null 2>&1 || return

  nix-update \
    --quiet \
    --flake \
    --use-update-script \
    "$package" || return

  rm --force "result"
}

bump_scope() {
  local scope="${1:?scope at first argument is required}"

  local user_key="${scope//_/-}"
  printf '=%.0s' {1..16} >&2
  echo >&2
  echo "bump: ${user_key%:*}" >&2
  echo "processes: ${user_key#*:}" >&2
  local output
  output="$(nix eval --raw ".#maintained.${user_key%:*}")" || return
  local -a packages
  read -ra packages <<<"$output"
  echo "count: ${#packages[@]}" >&2
  printf '=%.0s' {1..16} >&2
  echo >&2

  local processes="${user_key#*:}"
  (

    if ((processes == 1)); then
      for package in "${packages[@]}"; do
        echo "bump: $package"
        nix_update "$package" || return
      done
    else
      export -f nix_update
      printf '%s\n' "${packages[@]}" |
        xargs \
          --max-args 1 \
          --max-procs "${user_key#*:}" \
          bash -c "nix_update \"\$1\"" _ ||
        return
    fi
  )
}

bump() {
  declare -A scopes

  for key in "packages:4" "vscode_extensions:8"; do
    scopes[$key]=0
  done

  while [[ $# -gt 0 ]]; do
    local known=0
    for key in "${!scopes[@]}"; do
      user_key="${1//-/_}"
      if [[ $user_key == "${key%:*}" ]]; then
        scopes[$key]=1
        shift 1
        known=1
      fi
    done
    if [[ $known == 0 ]]; then
      echo "unknown key! $1" >&2
      exit 1
    fi
  done

  local all=1
  for value in "${scopes[@]}"; do
    if ((value == 1)); then
      all=0
      break
    fi
  done
  if ((all == 1)); then
    for key in "${!scopes[@]}"; do
      scopes[$key]=1
    done
  fi

  for key in "${!scopes[@]}"; do
    value="${scopes[$key]}"
    if [[ $value == 0 ]]; then
      continue
    fi

    bump_scope "$key" || return
  done
}
