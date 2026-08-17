### [options.my](module-list.nix)

| name | type | default |
| ---- | ---- | ------- |
| [audio.enable](any/audio.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [development.cpp.clion](any/development.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [development.cpp.enable](any/development.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [development.cpp.qt](any/development.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [development.enable](any/development.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [development.nixos.enable](any/development.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [development.nixos.startup](any/development.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [development.python.enable](any/development.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [explorer.dolphin](any/explorer.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | true |
| [explorer.enable](any/explorer.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | true |
| [explorer.yazi](any/explorer.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | true |
| [gaming.enable](any/gaming.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [gaming.steam](any/gaming.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [gaming.vr](any/gaming.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [host](any/host.nix) | [str](https://nixos.org/manual/nixos/stable/#sec-option-types) |  |
| [image.comfy-ui.enable](any/image.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [image.enable](any/image.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | true |
| [monitoring.enable](any/monitoring.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [monitoring.run](any/monitoring.nix) | [path](https://nixos.org/manual/nixos/stable/#sec-option-types) |  |
| [music.enable](any/music.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [music.startup](any/music.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [office.enable](any/office.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [social.enable](any/social.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [theme.colorScheme.accent](any/theme.nix) | [str](https://nixos.org/manual/nixos/stable/#sec-option-types) |  |
| [theme.colorScheme.flavor](any/theme.nix) | [str](https://nixos.org/manual/nixos/stable/#sec-option-types) |  |
| [theme.colorScheme.palette](any/theme.nix) | [attrsOf](https://nixos.org/manual/nixos/stable/#sec-option-types) |  |
| [theme.cursor.enable](any/theme.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [theme.cursor.name](any/theme.nix) | [str](https://nixos.org/manual/nixos/stable/#sec-option-types) |  |
| [theme.cursor.path](any/theme.nix) | [path](https://nixos.org/manual/nixos/stable/#sec-option-types) |  |
| [theme.enable](any/theme.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | true |
| [theme.icons.enable](any/theme.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | true |
| [theme.icons.local](any/theme.nix) | [attrsOf](https://nixos.org/manual/nixos/stable/#sec-option-types) | {} |
| [video.enable](any/video.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [video.export.blackmagic](any/video.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [video.export.enable](any/video.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [video.import.enable](any/video.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | true |
| [web.browser](any/web.nix) | [package](https://nixos.org/manual/nixos/stable/#sec-option-types) |  |
| [web.enable](any/web.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | true |
| [wifi-interface](any/host.nix) | [str](https://nixos.org/manual/nixos/stable/#sec-option-types) |  |
| [windows.enable](any/windows.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [wm.enable](any/wm.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | false |
| [wm.niri.display.first](any/wm.nix) | [str](https://nixos.org/manual/nixos/stable/#sec-option-types) |  |
| [wm.niri.display.second](any/wm.nix) | [str](https://nixos.org/manual/nixos/stable/#sec-option-types) |  |
| [wm.niri.enable](any/wm.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | true |
| [wm.niri.run-visible](any/wm.nix) | [str](https://nixos.org/manual/nixos/stable/#sec-option-types) | spawn-at-startup |
| [wm.niri.startups](any/wm.nix) | [nullOr](https://nixos.org/manual/nixos/stable/#sec-option-types) | null |
| [wm.niri.themes](any/wm.nix) | [nullOr](https://nixos.org/manual/nixos/stable/#sec-option-types) | null |
| [wm.niri.windows](any/wm.nix) | [nullOr](https://nixos.org/manual/nixos/stable/#sec-option-types) | null |
| [wm.niri.workspaces](any/wm.nix) | [nullOr](https://nixos.org/manual/nixos/stable/#sec-option-types) | null |
| [wm.vicinae.enable](any/wm.nix) | [bool](https://nixos.org/manual/nixos/stable/#sec-option-types) | true |
