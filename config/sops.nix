{
  ...
}:
{
  sops = {
    defaultSopsFile = ../secrets.yaml;
    age = {
      sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      "users/olimpik/ssh" = {
        path = "/home/olimpik/.ssh/id_ed25519";
        owner = "olimpik";
      };
      "users/olimpik/gpg" = {
        owner = "olimpik";
      };
      "networking/ax3_2" = { };
      "networking/ax3_5" = { };
      "networking/ax1500_5" = { };
      "nix/cache" = {
        mode = "0600";
      };
    };
  };
}
