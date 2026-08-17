{
  config,
  lib,
  lib-o,

  pkgs-s,
  pkgs-o,
  ...
}:
let
  cfg = config.programs.vscode.my;
in
{
  options.programs.vscode.my = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    config = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    bash = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    nix = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    cpp = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    qt = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    python = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    remote = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib-o.mkIf cfg.enable {
    hm =
      let
        mkDefault = condition: content: lib.mkIf condition { programs.vscode.profiles.default = content; };
      in
      lib.mkMerge [
        (mkDefault cfg.config {
          userSettings = {
            "redhat.telemetry.enabled" = false;
            "xml.codeLens.enabled" = true;
            "xml.java.home" = "${pkgs-s.openjdk}";
            "[shellscript]" = {
              "editor.tabSize" = 2;
              "editor.insertSpaces" = true;
              "editor.detectIndentation" = false;
            };
          };
          extensions = with pkgs-o.vscode-extensions; [
            kdl-org.kdl
            redhat.vscode-xml
          ];
        })
        (mkDefault cfg.bash {
          userSettings = {
            "shellcheck.executablePath" = "${lib.getExe pkgs-s.shellcheck}";
            "shellcheck.exclude" = [
              "SC2148"
            ];
            "shfmt.executablePath" = "${lib.getExe pkgs-s.shfmt}";
            "shfmt.executableArgs" = [
              "--indent"
              "2"
              "--simplify"
            ];
          };
          extensions = with pkgs-o.vscode-extensions; [
            mkhl.shfmt
            timonwong.shellcheck
          ];
        })
        (mkDefault cfg.nix {
          extensions = with pkgs-o.vscode-extensions; [
            coopermaruyama.nix-embedded-languages
            jnoortheen.nix-ide
          ];
        })
        (mkDefault cfg.cpp {
          userSettings = {
            "cmakeFormatter.gersemiPath" = "${lib.getExe pkgs-s.gersemi}";
            "cmakeFormatter.lineWidth" = "120";
          };
          extensions = with pkgs-o.vscode-extensions; [
            alexandar-djordjevic.gersemi-cmake-formatter
            llvm-vs-code-extensions.lldb-dap
            llvm-vs-code-extensions.vscode-clangd
            ms-vscode.cmake-tools
            ms-vscode.cpp-devtools
            ms-vscode.cpptools
            ms-vscode.cpptools-extension-pack
            ms-vscode.cpptools-themes
          ];
        })
        (mkDefault cfg.qt {
          extensions = with pkgs-o.vscode-extensions; [
            theqtcompany.qt-core
            theqtcompany.qt-python
            theqtcompany.qt-qml
            theqtcompany.qt-ui
          ];
        })
        (mkDefault cfg.python {
          extensions = with pkgs-o.vscode-extensions; [
            ms-python.debugpy
            ms-python.python
            ms-python.vscode-pylance
            ms-python.vscode-python-envs
            kevinrose.vsc-python-indent
          ];
        })
        (mkDefault cfg.remote {
          extensions = with pkgs-o.vscode-extensions; [
            ms-vscode-remote.remote-containers
            ms-vscode-remote.remote-ssh
            ms-vscode-remote.remote-ssh-edit
            ms-vscode.remote-explorer
            ms-vscode.remote-repositories
            ms-vscode.remote-server
          ];
        })
      ];
  };
}
