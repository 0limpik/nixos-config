{
  lib,
  ...
}:
{
  options.my = {
    host = lib.mkOption {
      type = lib.types.str;
    };
    wifi-interface = lib.mkOption {
      type = lib.types.str;
    };
  };
}
