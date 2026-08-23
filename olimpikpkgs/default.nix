let
  system = "x86_64-linux";
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nodeName = lock.nodes.root.inputs.flake-compat;
  flakeCompatSrc = builtins.fetchTarball {
    url =
      lock.nodes.${nodeName}.locked.url
        or "https://github.com/edolstra/flake-compat/archive/${lock.nodes.${nodeName}.locked.rev}.tar.gz";
    sha256 = lock.nodes.${nodeName}.locked.narHash;
  };
  flakeCompat = import flakeCompatSrc;
  flake =
    (flakeCompat {
      src = ./.;
      inherit system;
    }).defaultNix;
in
flake.packages.${system}
