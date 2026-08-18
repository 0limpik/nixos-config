{
  pkgs-s,
  ...
}:
{
  my = {
    audio = {
      enable = true;
    };
    gaming = {
      enable = true;
      steam = true;
      vr = true;
    };
    wm = {
      enable = true;
      niri.display = {
        first = "LG Electronics LG ULTRAWIDE 0x00060B28";
        second = "Samsung Electric Company SMS22A450 HLPBB00340";
      };
    };
    image = {
      enable = true;
      comfy-ui.enable = true;
    };
    video = {
      enable = true;
      export = {
        enable = true;
        blackmagic = true;
      };
    };
    windows = {
      enable = true;
    };
    monitoring = {
      enable = true;
    };
  };

  environment = {
    systemPackages = [
      pkgs-s.home-manager
    ];
  };
}
