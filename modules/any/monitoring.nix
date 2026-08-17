{
  config,
  lib,
  lib-o,

  pkgs-s,
  pkgs-u,
  pkgs-o,
  ...
}:
let
  cfg = config.my.monitoring;
in
{
  options.my.monitoring = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    run = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = lib-o.mkIf cfg.enable (
    let
      packages = [
        pkgs-s.htop
        pkgs-s.iftop
        pkgs-u.nvtopPackages.amd
        pkgs-u.amdgpu_top
        pkgs-s.lact
        pkgs-o.mission-center
        pkgs-o.mission-center.run
        pkgs-s.nethogs
        pkgs-s.gparted
      ];
    in
    {
      os = {
        environment.systemPackages = packages;
        security.wrappers.nethogs = {
          source = "${pkgs-s.nethogs}/bin/nethogs";
          capabilities = "cap_net_admin,cap_net_raw,cap_dac_read_search,cap_sys_ptrace+pe";
          owner = "root";
          group = "root";
        };
      };
      hm = {
        home.packages = packages;
      };
      any = {
        my.monitoring.run = lib.getExe pkgs-o.mission-center.run;
      };
    }
  );
}
