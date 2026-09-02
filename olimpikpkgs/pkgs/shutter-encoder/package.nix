{
  lib,
  stdenvNoCC,
  buildFHSEnv,
  fetchFromGitHub,
  makeWrapper,
  stripJavaArchivesHook,
  copyDesktopItems,
  makeDesktopItem,
  callPackage,

  jdk25,
  jre25_minimal,

  ffmpeg,
  _7zz,
  exiftool,
  dcraw,
  yt-dlp,
  dvdauthor,
  tsmuxer,
  mediainfo,
  bmx,
  xpdf,
  realesrgan-ncnn-vulkan,
}:
let
  version = "20.3";
  src = fetchFromGitHub {
    owner = "paulpacifico";
    repo = "shutter-encoder";
    rev = version;
    hash = "sha256-pt/qosD5NARcCGWZJwnIH7q0o/7ME+sEnj9Ug6/H/lY=";
  };
  jre =
    (jre25_minimal.override {
      modules = [
        "java.base"
        "java.datatransfer"
        "java.desktop"
        "java.logging"
        "java.security.sasl"
        "java.xml"
        "jdk.crypto.ec"
      ];
    }).overrideAttrs
      (attrs: {
        inherit src;
        dontUnpack = false;
        dontInstall = false;

        postInstall = ''
          mkdir -p "$out/lib/fonts"
          cp -r "./fonts/"* "$out/lib/fonts/"
        '';
      });
  shutter-encoder = stdenvNoCC.mkDerivation rec {
    pname = "shutter-encoder-unwrapped";
    inherit src version;
    nativeBuildInputs = [
      jdk25
      stripJavaArchivesHook
      makeWrapper
      copyDesktopItems
    ];

    buildInputs = [
      jre
      ffmpeg
      _7zz
      exiftool
      dcraw
      yt-dlp
      dvdauthor
      tsmuxer
      mediainfo
      bmx
      realesrgan-ncnn-vulkan
    ];

    patchPhase = ''
      substituteInPlace "./src/shutterencoder/library/PDF.java" \
        --replace-fail 'VideoPlayer' 'VideoPlayerUI' \
        --replace-fail \
          'import shutterencoder.ui.videoplayer.VideoPlayerUI;' \
          '
          import shutterencoder.ui.videoplayer.VideoPlayerUI;
          import shutterencoder.ui.videoplayer.VideoPlayerCore;
          import shutterencoder.ui.videoplayer.VideoPlayerUtils;
          ' \
        --replace-fail 'VideoPlayerUI.preview' 'VideoPlayerCore.preview' \
        --replace-fail 'VideoPlayerUI.videoPath' 'VideoPlayerCore.videoPath' \
        --replace-fail \
          'VideoPlayerCore.preview = converted;' \
          'VideoPlayerCore.preview = ((java.awt.image.DataBufferByte) converted.getRaster().getDataBuffer()).getData();' \
        --replace-fail 'VideoPlayerUI.setInfo();' 'VideoPlayerUtils.setInfo();'

      substituteInPlace "./src/shutterencoder/ui/main/Shutter.java" \
        --replace-fail \
          'public static File documents = new File(System.getProperty("user.home") + "/Shutter Encoder");' \
          '
          public static File documents = new File(
              System.getProperty("os.name").contains("Linux")
                  ? (System.getenv("XDG_CONFIG_HOME") != null ? System.getenv("XDG_CONFIG_HOME") : System.getProperty("user.home") + "/.config") + "/shutter-encoder"
              : System.getProperty("os.name").contains("Mac")
                  ? System.getProperty("user.home") + "/Library/Application Support/Shutter Encoder"
              : System.getProperty("user.home") + "/Shutter Encoder"
          );
          '

      substituteInPlace "./src/shutterencoder/utils/Utils.java" \
        --replace-fail \
        'new ProcessBuilder(launcher).start();' \
        '
          if (launcher != null) {
              new ProcessBuilder(launcher).start();
          } else {
              new ProcessBuilder("/bin/bash", "-c" , "shutter-encoder").start();
          }
        '
    '';

    buildPhase = ''
      runHook preBuild

      BUILD="./build"
      mkdir --parents "$BUILD"
      javac \
       -d "$BUILD" \
       --class-path \
        "./src/libs/*" \
        $(find "./src/shutterencoder" -name "*.java")

      mkdir --parents "$BUILD/resources"
      cp --recursive "./src/resources/"* "$BUILD/resources/"

      MANIFEST="./manifest.txt"
      cat << EOF > "$MANIFEST"
      Manifest-Version: 1.0
      Main-Class: shutterencoder.ui.main.Shutter
      Class-Path: $(
        find "./src/libs" -name '*.jar' -printf 'libs/%f ' \
        | paste -sd' ' -
      )
      Implementation-Title: Shutter Encoder
      Implementation-Version: ${version}
      Implementation-Vendor: Pacifico Paul
      EOF
      JAR="./shutter-encoder.jar"
      jar \
        --create \
        --file "$JAR" \
        --manifest "$MANIFEST" \
        -C "$BUILD" ./

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -D "$JAR" "$out/share/shutter-encoder.jar"
      install -D "./src/resources/icon.png" "$out/share/icons/hicolor/256x256/apps/shutter-encoder.png"

      mkdir --parents "$out/share/libs"
      cp --recursive "./src/libs/"* "$out/share/libs/"

      mkdir --parents "$out/share/Languages"
      cp --recursive "./Languages/"* "$out/share/Languages/"

      LIBRARY="$out/share/Library"
      mkdir --parents "$LIBRARY"
      ln --symbolic "${ffmpeg}/bin/ffmpeg" "$LIBRARY/ffmpeg"
      ln --symbolic "${ffmpeg}/bin/ffprobe" "$LIBRARY/ffprobe"
      ln --symbolic "${_7zz}/bin/7zz" "$LIBRARY/7zz"
      ln --symbolic "${exiftool}/bin/exiftool" "$LIBRARY/exiftool"
      ln --symbolic "${dcraw}/bin/dcraw" "$LIBRARY/dcraw_emu"
      ln --symbolic "${yt-dlp}/bin/yt-dlp" "$LIBRARY/yt-dlp_linux"
      ln --symbolic "${dvdauthor}/bin/dvdauthor" "$LIBRARY/dvdauthor"
      ln --symbolic "${tsmuxer}/bin/tsmuxer" "$LIBRARY/tsMuxeR"
      ln --symbolic "${mediainfo}/bin/mediainfo" "$LIBRARY/mediainfo"
      ln --symbolic "${bmx}/bin/bmxtranswrap" "$LIBRARY/bmxtranswrap"
      ln --symbolic "${xpdf}/bin/pdfinfo" "$LIBRARY/pdfinfo"
      ln --symbolic "${xpdf}/bin/pdftoppm" "$LIBRARY/pdftoppm"
      ln --symbolic "${realesrgan-ncnn-vulkan}/bin/realesrgan-ncnn-vulkan" "$LIBRARY/realesrgan-ncnn-vulkan"
      cp "./Library/colorize.py" "$LIBRARY"

      mkdir --parents "$out/bin"
      makeWrapper "${jre}/bin/java" "$out/bin/shutter-encoder" \
        --argv0 "shutter-encoder" \
        --set "_JAVA_AWT_WM_NONREPARENTING" "1" \
        --add-flags "-Xmx4G" \
        --add-flags "-Dawt.useSystemAAFontSettings=lcd" \
        --add-flags "-Dswing.aatext=true" \
        --add-flags "-jar $out/share/shutter-encoder.jar"

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "shutter-encoder";
        desktopName = "Shutter Encoder";
        genericName = "Video Editor";
        icon = "shutter-encoder";
        categories = [
          "Application"
          "Video"
          "Audio"
          "AudioVideo"
          "Compression"
          "Utility"
        ];
        exec = "shutter-encoder";
      })
    ];
  };
in
buildFHSEnv (
  let
    config = "$XDG_CONFIG_HOME/shutter-encoder";
  in
  {
    pname = "shutter-encoder";
    inherit (shutter-encoder) version;
    targetPkgs =
      pkgs: with pkgs; [
        bash
      ];
    extraInstallCommands = ''
      mkdir --parents \
        "$out/share/applications" \
        "$out/share/icons/hicolor/256x256/apps"

      ln --symbolic "${shutter-encoder}/share/applications/"*.desktop "$out/share/applications"/
      ln --symbolic "${shutter-encoder}/share/icons/hicolor/256x256/apps/"*.png "$out/share/icons/hicolor/256x256/apps"/
    '';
    extraPreBwrapCmds = ''
      mkdir --parents "${config}/Library" "${config}/Functions"
      ${lib.optionalString stdenvNoCC.isLinux ''
        ln --symbolic --force "${lib.getExe yt-dlp}" "${config}/Library/yt-dlp_linux"
      ''}
      ${lib.optionalString stdenvNoCC.isDarwin ''
        ln --symbolic --force "${lib.getExe yt-dlp}" "${config}/Library/yt-dlp_macos"
      ''}
    '';
    runScript = "${shutter-encoder}/bin/shutter-encoder";

    passthru = {
      inherit src;
    };
    meta = {
      description = "A professional video compression tool accessible to all, mostly based on FFmpeg.";
      homepage = "https://www.shutterencoder.com";
      license = lib.licenses.gpl3;
      maintainers = with lib.maintainers; [ olimpik ];
      mainProgram = "shutter-encoder";
    };
  }
)
