{
  callPackage,
  stdenvNoCC,
  copyDesktopItems,
  makeDesktopItem,

  libarchive,
  unzip,
  pv,
  appimageTools,
  addDriverRunpath,

  libGLU,
  libXxf86vm,
}:
stdenvNoCC.mkDerivation rec {
  pname = "davinci-resolve-studio";
  version = src.version;

  src = callPackage ./fetcher.nix {
    platform = stdenvNoCC.hostPlatform.uname.system;
    product = "davinci-resolve-studio";
    version = "21.0.4";
    hash = "sha256-FwaSnK3DAIRGCz6kiWxE4o0Cd0en2qoyuWCDHat1xHQ=";
  };

  nativeBuildInputs = [
    libarchive
    unzip
    pv
    appimageTools.appimage-exec
    addDriverRunpath
    copyDesktopItems
  ];

  buildInputs = [
    libGLU
    libXxf86vm
  ];

  APPIMAGE_NAME = "DaVinci_Resolve_Studio_${version}_Linux.run";

  unpackPhase = ''
    unzip -q "$src" -d "./"
    mkdir --parents "$out"
    test -n "$APPIMAGE_NAME"
    appimage-exec.sh -x "$out" "$APPIMAGE_NAME"
  '';

  required_dirs = builtins.concatStringsSep "," [
    ".crashreport"
    ".license"
    ".LUT"
    "\"Apple Immersive/Calibration\""
    "\"Resolve Disk Database\""
    "configs"
    "DolbyVision"
    "easyDCP"
    "Extras"
    "Fairlight"
    "GPUCache"
    "IOPlugins"
    "lib"
    "logs"
    "Media"
  ];

  installPhase = ''
    runHook preInstall

    export HOME="$PWD/home"
    mkdir --parents "$HOME"

    mkdir --parents "$out"

    mkdir --parents "$out"/{${required_dirs}}

    tar --extract --file "$out/share/panels/dvpanel-framework-linux-x86_64.tgz" --directory "$out/lib"

    mkdir --parents "$out/lib/udev/rules.d"
    cp "$out/share/etc/udev/rules.d/99-BlackmagicDevices.rules" "$out/lib/udev/rules.d"/
    cp "$out/share/etc/udev/rules.d/99-ResolveKeyboardHID.rules" "$out/lib/udev/rules.d"/
    cat << EOF > "$out/lib/udev/rules.d/99-DavinciPanel.rules"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="096e", MODE="0666"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="096e", MODE="0666"
    EOF

    runHook postInstall
  '';

  dontStrip = true;

  postFixup = ''
    for program in "$out/bin"/*; do
      isELF "$program" || continue
      addDriverRunpath "$program"
    done

    for program in "$out/libs"/*; do
      isELF "$program" || continue
      if [[ "$program" != *"libcudnn_cnn_infer"* ]];then
        addDriverRunpath "$program"
      fi
    done
    ln --symbolic "$out/libs/libcrypto.so.1.1" "$out/libs/libcrypt.so.1"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "DaVinciResolve";
      desktopName = "Davinci Resolve Studio";
      genericName = "DaVinci Resolve";
      exec = "davinci-resolve-studio";
      icon = "davinci-resolve-studio";
      comment = "Revolutionary new tools for editing, visual effects, color correction and professional audio post production, all in a single application!";
      mimeTypes = [
        "application/x-resolveproj"
      ];
      startupNotify = false;
      categories = [
        "AudioVideo"
        "AudioVideoEditing"
        "Video"
        "Graphics"
      ];
      startupWMClass = "resolve";
    })
    (makeDesktopItem {
      name = "DaVinciResolveCaptureLogs";
      desktopName = "Capture Logs";
      genericName = "Capture Logs";
      icon = "applications-system";
      exec = "davinci-resolve-caputre-logs";
    })
    (makeDesktopItem {
      name = "DaVinciRemoteMonitoring";
      desktopName = "DaVinci Remote Monitor";
      genericName = "Remote Monitor";
      comment = "DaVinci Remote Monitor";
      icon = "davinci-remote-monitor";
      exec = "davinci-remote-monitor";
    })
    (makeDesktopItem {
      name = "DaVinciControlPanelsSetup";
      desktopName = "DaVinci Control Panels Setup";
      genericName = "Control Panels Setup";
      icon = "davinci-control-panels-setup";
      categories = [
        "Settings"
      ];
      exec = "davinci-control-panels-setup";
    })
    (makeDesktopItem {
      name = "davinci-fairlight-studio-utility";
      desktopName = "Fairlight Studio Utility";
      exec = "davinci-fairlight-studio-utility";
      icon = "davinci-resolve-studio";
      categories = [
        "AudioVideo"
        "Audio"
      ];
    })
    (makeDesktopItem {
      name = "blackmagicraw-player";
      desktopName = "Blackmagic RAW Player";
      icon = "blackmagicraw-player";
      mimeTypes = [
        "application/x-braw-clip"
        "application/x-braw-sidecar"
      ];
      categories = [
        "AudioVideo"
        "Video"
      ];
      exec = "blackmagicraw-player %f";
    })
    (makeDesktopItem {
      name = "blackmagicraw-speedtest";
      desktopName = "Blackmagic RAW Speed Test";
      icon = "blackmagicraw-speedtest";
      categories = [
        "AudioVideo"
        "Video"
      ];
      exec = "blackmagicraw-speedtest";
    })
    (makeDesktopItem {
      name = "DaVinciResolve";
      desktopName = "DaVinci Resolve";
      icon = "davinci-resolve-studio";
      type = "Directory";
    })
  ];
}
