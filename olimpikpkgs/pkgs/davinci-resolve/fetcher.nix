{
  lib,
  stdenv,
  runCommandLocal,
  cacert,
  curl,
  jq,
  pv,

  platform ? stdenv.hostPlatform.uname.system,
  product,
  version,
  hash,
}:
runCommandLocal "source"
  {
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = hash;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars;

    nativeBuildInputs = [
      curl
      jq
      pv
    ];

    passthru = {
      inherit platform product version;
    };

    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

    PLATFORM = platform;
    PRODUCT = product;
    VERSION = version;

    ARCHIVE_URL_USERAGENT = builtins.concatStringsSep " " [
      "User-Agent: Mozilla/5.0 (X11; Linux ${stdenv.hostPlatform.linuxArch})"
      "AppleWebKit/537.36 (KHTML, like Gecko)"
      "Chrome/77.0.3865.75"
      "Safari/537.36"
    ];
    ARCHIVE_URL_REFFERER = "263d62f31cbb49e0868005059abcb0c9";
    ARCHIVE_URL_BODY = builtins.toJSON {
      "firstname" = "NixOS";
      "lastname" = "Linux";
      "email" = "someone@nixos.org";
      "phone" = "+31 71 452 5670";
      "country" = "nl";
      "street" = "-";
      "state" = "Province of Utrecht";
      "city" = "Utrecht";
      "product" = product;
    };
  }
  ''
    source ${./shared.sh}
    source ${./fetcher.sh}
    source ${./fetcher}
  ''
