{
  lib,
  callPackage,
  writeText,
  writeShellScript,
  writeShellApplication,
  bash,
  xkeyboard_config,
  curl,
  jq,
  common-updater-scripts,
  buildFHSEnv,
  buildEnv,
}:
let
  davinci = callPackage ./unwrapped.nix { };
  FHSEnv = {
    inherit (davinci) pname version;

    targetPkgs =
      pkgs: with pkgs; [
        alsa-lib
        aprutil
        bzip2
        davinci
        dbus
        expat
        fontconfig
        freetype
        glib
        libGL
        libGLU
        libarchive
        libcap
        librsvg
        libtool
        libuuid
        libxcrypt # provides libcrypt.so.1
        libxkbcommon
        nspr
        ocl-icd
        opencl-headers
        python3
        python3.pkgs.numpy
        udev
        xdg-utils # xdg-open needed to open URLs
        libice
        libsm
        libx11
        libxcomposite
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxi
        libxinerama
        libxrandr
        libxrender
        libxt
        libxtst
        libxxf86vm
        libxcb
        libxcb-util
        libxcb-image
        libxcb-keysyms
        libxcb-render-util
        libxcb-wm
        xkeyboard-config
        zlib

        libdrm # libdrm.so.2 needed by bundled Qt6 WebEngine (Control Panels Setup)
        libxkbfile # libxkbfile.so.1 needed by bundled Qt6 WebEngine (Control Panels Setup)
        krb5 # libgssapi_krb5.so.2 needed by bundled Qt6 (Control Panels Setup, Fairlight Studio Utility)
        nss # libsmime3.so needed by bundled Qt6 (Control Panels Setup)
        libxcb-cursor # libxcb-cursor.so needed by Qt6 xcb platform plugin (Fairlight Studio Utility)

        (blackmagic-desktop-video.overrideAttrs (attrs: rec {
          version = "16.1";
          src =
            (pkgs.callPackage ./fetcher.nix {
              product = "desktop-video";
              inherit version;
              hash = "sha256-6TL5NhexOydD8qBjKAVLuaMTFTlWK4M8XSYHfUxCNMc=";
            }).overrideAttrs
              (attrs: {
                name = "${attrs.name}.tar";
              });
        }))
      ];

    extraPreBwrapCmds = ''
      mkdir --parents "$HOME/.local/share/DaVinciResolve/license" || exit 1
      mkdir --parents "$HOME/.local/share/DaVinciResolve/Extras" || exit 1
      mkdir --parents "$HOME/.local/share/DaVinciResolve/logs" || exit 1
    ''
    # media issue
    # https://www.reddit.com/r/davinciresolve/comments/1sq2iop/how_to_prevent_davinci_resolve_from_creating_a/
    + ''
      mkdir --parents "$HOME/.local/share/DaVinciResolve/DaVinci Resolve Media" || exit 1
    '';

    extraBwrapArgs = [
      ''--bind "$HOME/.local/share/DaVinciResolve/license" "${davinci}/.license"''
      ''--bind "$HOME/.local/share/DaVinciResolve/Extras" "${davinci}/Extras"''
      ''--bind "$HOME/.local/share/DaVinciResolve/logs" "${davinci}/logs"''
      # media issue
      ''--symlink "$HOME/.local/share/DaVinciResolve/DaVinci Resolve Media" "$HOME/DaVinci Resolve Media"''
    ];

    runScript = "${bash}/bin/bash ${writeText "davinci-wrapper" ''
      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib:/usr/lib32"
      unset QT_STYLE_OVERRIDE
      export QT_XKB_CONFIG_ROOT="${xkeyboard_config}/share/X11/xkb"
      export LOG4CXX_CONFIGURATION="${davinci}/share/log-conf.xml"

      exec "$@"
    ''}";

    extraInstallCommands =
      let
        mkWrapper =
          name:
          {
            bin,
            libs ? "${davinci}/libs",
            plugins ? "${davinci}/libs/plugins",
          }:
          writeShellScript name ''
            export QT_PLUGIN_PATH="${plugins}:$QT_PLUGIN_PATH"
            export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${libs}"
            ${
              # media-issue
              if (name == "davinci-resolve-studio") then
                ''
                  "${bin}" "$@"
                  rm --force "$HOME/DaVinci Resolve Media"
                ''
              else
                ''
                  exec "${bin}" "$@"
                ''
            }
          '';
        wrappers = {
          "davinci-resolve-studio" = {
            bin = "${davinci}/bin/resolve";
          };
          "davinci-control-panels-setup" = {
            bin = "${davinci}/DaVinci Control Panels Setup/DaVinci Control Panels Setup";
            libs = "${davinci}/DaVinci Control Panels Setup";
            plugins = "${davinci}/DaVinci Control Panels Setup/plugins";
          };
          "blackmagic-remote-monitor" = {
            bin = "${davinci}/bin/Blackmagic Remote Monitor";
          };
          "blackmagicraw-speedtest" = {
            bin = "${davinci}/BlackmagicRAWSpeedTest/BlackmagicRAWSpeedTest";
            libs = "${davinci}/BlackmagicRAWSpeedTest/lib";
            plugins = "${davinci}/BlackmagicRAWSpeedTest/plugins";
          };
          "blackmagicraw-player" = {
            bin = "${davinci}/BlackmagicRAWPlayer/BlackmagicRAWPlayer";
            libs = "${davinci}/BlackmagicRAWPlayer/lib";
            plugins = "${davinci}/BlackmagicRAWPlayer/plugins";
          };
        };
      in
      ''
        mkdir --parents \
          "$out/share/applications" \
          "$out/share/icons/hicolor/48x48/apps" \
          "$out/share/icons/hicolor/128x128/apps" \
          "$out/share/icons/hicolor/256x256/apps" \
          "$out/share/icons/hicolor/48x48/mimetypes" \
          "$out/share/icons/hicolor/256x256/mimetypes" \
          "$out/share/mime/packages"

        ln --symbolic "${davinci}/share/applications"/* "$out/share/applications"/
        ln --symbolic "${davinci}/graphics/DV_Resolve.png" "$out/share/icons/hicolor/128x128/apps/davinci-resolve-studio.png"
        ln --symbolic "${davinci}/graphics/Remote_Monitoring.png" "$out/share/icons/hicolor/128x128/apps/davinci-remote-monitor.png"
        ln --symbolic "${davinci}/graphics/DV_Panels.png" "$out/share/icons/hicolor/128x128/apps/davinci-control-panels-setup.png"

        ln --symbolic "${davinci}/graphics/blackmagicraw-player_48x48_apps.png" "$out/share/icons/hicolor/48x48/apps/blackmagicraw-player.png"
        ln --symbolic "${davinci}/graphics/blackmagicraw-player_256x256_apps.png" "$out/share/icons/hicolor/256x256/apps/blackmagicraw-player.png"
        ln --symbolic "${davinci}/graphics/blackmagicraw-speedtest_48x48_apps.png" "$out/share/icons/hicolor/48x48/apps/blackmagicraw-speedtest.png"
        ln --symbolic "${davinci}/graphics/blackmagicraw-speedtest_256x256_apps.png" "$out/share/icons/hicolor/256x256/apps/blackmagicraw-speedtest.png"

        ln --symbolic "${davinci}/graphics/application-x-braw-clip_48x48_mimetypes.png" "$out/share/icons/hicolor/48x48/mimetypes/application-x-braw-clip.png"
        ln --symbolic "${davinci}/graphics/application-x-braw-clip_256x256_mimetypes.png" "$out/share/icons/hicolor/256x256/mimetypes/application-x-braw-clip.png"
        ln --symbolic "${davinci}/graphics/application-x-braw-sidecar_48x48_mimetypes.png" "$out/share/icons/hicolor/48x48/mimetypes/application-x-braw-sidecar.png"
        ln --symbolic "${davinci}/graphics/application-x-braw-sidecar_256x256_mimetypes.png" "$out/share/icons/hicolor/256x256/mimetypes/application-x-braw-sidecar.png"

        ln --symbolic "${davinci}/share/mime/packages"/* "$out/share/mime/packages"/

        mkdir --parents "$out/lib/udev/rules.d"
        ln --symbolic "${davinci}/lib/udev/rules.d/99-BlackmagicDevices.rules" "$out/lib/udev/rules.d"/
        ln --symbolic "${davinci}/lib/udev/rules.d/99-ResolveKeyboardHID.rules" "$out/lib/udev/rules.d"/
        ln --symbolic "${davinci}/lib/udev/rules.d/99-DavinciPanel.rules" "$out/lib/udev/rules.d"/

        mv "$out/bin/${davinci.pname}" "$out/bin/${davinci.pname}-fhs"

        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: attr: ''
            cat << EOF > "$out/bin/${name}"
              "$out/bin/${davinci.pname}-fhs" "${mkWrapper name attr}"
            EOF
            chmod +x "$out/bin/${name}"
          '') wrappers
        )}
      '';

    passthru = {
      inherit davinci;
      updateScript = lib.getExe (writeShellApplication {
        name = "update-davinci-resolve";
        runtimeInputs = [
          curl
          jq
          common-updater-scripts
        ];
        runtimeEnv = with davinci.src; {
          PLATFORM = platform;
          PRODUCT = product;
          VERSION = version;
        };
        text = ''
          # shellcheck disable=SC1091
          source "${./shared.sh}"
          # shellcheck disable=SC1091
          source "${./latest-version.sh}"
          latest_version="$(get_latest_version "$PLATFORM" "$PRODUCT" "$VERSION")"
          update-source-version \
            "davinci-resolve-studio" "$latest_version" \
            "--file=./pkgs/davinci-resolve/unwrapped.nix" \
            "--source-key=davinci.src"
        '';
      });
    };

    meta = {
      description = "Professional video editing, color, effects and audio post-processing";
      homepage = "https://www.blackmagicdesign.com/products/davinciresolve";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [ olimpik ];
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  };
in
buildFHSEnv (
  FHSEnv
  // {
    passthru = FHSEnv.passthru // {
      withEncoders =
        encoders:
        let
          encodersEnv = buildEnv {
            name = "${davinci.pname}-encoders";
            extraPrefix = "/IOPlugins/";
            paths = encoders;
          };
        in
        buildFHSEnv (
          FHSEnv
          // {
            extraBwrapArgs = FHSEnv.extraBwrapArgs ++ [
              ''--ro-bind "${encodersEnv}/IOPlugins" "${davinci}/IOPlugins"''
            ];
          }
        );
    };
  }
)
