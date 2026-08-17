{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_Blue_SN580_2TB_24021H803372";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
                extraArgs = [
                  "-n"
                  "BOOT"
                ];
              };
            };
            encryptedSwap = {
              size = "32G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            root = {
              size = "1024G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                extraArgs = [
                  "-n"
                  "NixOS"
                ];
              };
            };
            data = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/data";
                extraArgs = [
                  "-n"
                  "Data"
                ];
              };
            };
          };
        };
      };
    };
  };
}
