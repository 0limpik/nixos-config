{
  pkgs-s,
  pkgs-u,
  ...
}:
{
  imports = [
    ./theme.nix
  ];

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs-s; [
      corefonts
      vista-fonts
      noto-fonts
      noto-fonts-cjk-sans
    ];
  };

  programs = {
    dconf.enable = true;
    xwayland.enable = true;
  };

  environment = {
    systemPackages = [
      pkgs-s.home-manager
      pkgs-u.winbox4
    ];
    sessionVariables = {
      XDG_DATA_DIRS = [
        "${pkgs-s.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs-s.gsettings-desktop-schemas.name}"
        "${pkgs-s.gtk3}/share/gsettings-schemas/${pkgs-s.gtk3.name}"
      ];
      GSETTINGS_SCHEMA_DIR = "${pkgs-s.gtk3}/share/gsettings-schemas/${pkgs-s.gtk3.name}/glib-2.0/schemas";
    };
  };
}
