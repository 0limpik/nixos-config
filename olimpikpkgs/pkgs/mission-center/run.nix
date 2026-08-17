{
  writeShellApplication,
  systemd,
  procps,
}:
writeShellApplication rec {
  name = "missioncenter-run";
  runtimeInputs = [
    systemd
    procps
  ];
  text = /* bash */ ''
    launcher_name="''${1:?launcher_name at first argumet is required}"
    app="''${2:?app at second argumet is required.}"
    app_arguments=("''${@:3}")

    app_name="''${app%%:*}"
    if [[ "$app" == *:* ]]; then
      app_desktop="''${app#*:}"
    else
      app_desktop="''${app_name##*/}"
    fi
    random_string="$(od -An -N4 -tu4 /dev/urandom | tr -d ' ')"

    # https://gitlab.com/mission-center-devs/mission-center/-/wikis/Home/Apps
    exec systemd-run --scope --user \
      --unit="app-''${launcher_name}-$(systemd-escape "$app_desktop")-''${random_string}" \
      "$app_name" "''${app_arguments[@]}"
  '';
  meta.mainProgram = name;
}
