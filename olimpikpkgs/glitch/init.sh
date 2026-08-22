self="$(dirname "$(readlink --canonicalize "$0")")"

export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0=include.path
export GIT_CONFIG_VALUE_0="$self/git-config"

