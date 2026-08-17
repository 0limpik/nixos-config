{
  nix-update,
}:
nix-update.overrideAttrs {
  prePatch = /* bash */ ''
    substituteInPlace "./nix_update/utils.py" \
      --replace-fail "LOG_LEVEL < LogLevel.INFO" "LOG_LEVEL > LogLevel.INFO"
    substituteInPlace  "./nix_update/__init__.py" \
      --replace-fail "    print_maintainers(package)" '
        if not options.quiet:
            print_maintainers(package)
      '
  '';
}
