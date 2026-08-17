{
  config,
  osConfig,
  lib,
  lib-o,

  inputs,
  pkgs-s,
  pkgs-u,
  pkgs-o,
  ...
}:
let
  cfg = config.my.development;
in
{
  options.my.development = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    nixos = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      startup = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
    cpp = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      qt = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      clion = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
    python = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib-o.mkConfig (
        let
          packages = [
            pkgs-s.tree
            pkgs-s.jq
            pkgs-s.patchelf
            pkgs-s.nixfmt
            pkgs-s.nixd
            pkgs-s.nix-tree
            pkgs-s.nix-output-monitor
            pkgs-s.go-task
            pkgs-s.okteta
            pkgs-s.imhex
            pkgs-s.go
          ];
        in
        {
          os = {
            environment.systemPackages = packages;
          };
          hm = {
            home.packages = packages;
            programs = {
              vscode = {
                enable = true;
                my = {
                  enable = true;
                  config = true;
                  nix = true;
                  bash = true;
                  cpp = true;
                  qt = true;
                  python = true;
                  remote = true;
                };
                package = pkgs-s.vscode;
                profiles.default = {
                  userSettings = {
                    "chat.disableAIFeatures" = true;
                    "diffEditor.hideUnchangedRegions.enabled" = true;
                    "editor.fontFamily" = "JetBrains Mono";
                    "editor.fontLigatures" = true;
                    "files.simpleDialog.enable" = true;
                    "git.allowForcePush" = true;
                    "terminal.integrated.scrollback" = 100000;
                    "window.density.editorTabHeight" = "compact";
                    "window.dialogStyle" = "custom";
                    "workbench.editor.enablePreviewFromCodeNavigation" = true;
                    "workbench.editor.enablePreviewFromQuickOpen" = true;
                    "workbench.editor.highlightModifiedTabs" = true;
                    "workbench.editor.pinnedTabsOnSeparateRow" = true;
                    "workbench.editor.scrollToSwitchTabs" = true;
                    "workbench.editor.tabActionCloseVisibility" = false;
                    "workbench.editor.tabSizing" = "shrink";
                    "workbench.editor.tabSizingFixedMinWidth" = 38;
                    "workbench.editor.wrapTabs" = true;
                    "workbench.editorAssociations" = {
                      "{git,gitlens,chat-editing-snapshot-text-model,copilot,git-graph,git-graph-3}:/**/*.qrc" =
                        "default";
                      "{git,gitlens,chat-editing-snapshot-text-model,copilot,git-graph,git-graph-3}:/**/*.ui" = "default";
                      "*.qrc" = "qt-core.qrcEditor";
                    };
                  };
                };
              };
            };
            xdg.mimeApps = {
              enable = true;
              defaultApplications = {
                "text/x-nix" = [ "code.desktop" ];
                "text/plain" = [ "code.desktop" ];
                "application/x-extension-txt" = [ "code.desktop" ];
              };
            };
          };
        }
      ))
      (lib.mkIf cfg.cpp.enable (
        lib.mkMerge [
          (
            let
              packages = [
                pkgs-s.cmake
                pkgs-s.gnumake
                pkgs-s.meson
                pkgs-s.gdb
                pkgs-s.gf
                pkgs-s.gcc
                pkgs-s.clang-tools
                pkgs-s.valgrind
              ];
            in
            lib-o.mkConfig {
              os.environment.systemPackages = packages;
              hm = {
                home.packages = packages;
                programs.vscode.my.cpp = true;
              };
            }
          )
          (lib-o.mkIf cfg.cpp.qt {
            hm = {
              programs.vscode.my.qt = true;
            };
          })
          (lib-o.mkIf cfg.cpp.clion (
            let
              addPlugins = pkgs-u.jetbrains.plugins.addPlugins;
              package = (
                pkgs-u.jetbrains.clion.overrideAttrs (attrs: {
                  src = attrs.src.overrideAttrs (attrs: {
                    urls = lib.map (
                      url: lib.replaceStrings [ "download.jetbrains.com" ] [ "download-cdn.jetbrains.com" ] url
                    ) attrs.urls;
                  });
                })
              );
              plugins = inputs.nix-jetbrains-plugins.lib.pluginsForIde pkgs-u package [
                "com.intellij.plugins.watcher"
                "com.github.catppuccin.jetbrains"
                "com.github.catppuccin.jetbrains_icons"
                "nix-idea"
                #"slanglsp"
                #"com.redhat.devtools.lsp4ij"
              ];
              clion = addPlugins package (lib.attrValues plugins);
            in
            {
              os.environment.systemPackages = [ clion ];
              hm.home.packages = [ clion ];
            }
          ))
        ]
      ))
      (lib-o.mkIf cfg.python.enable (
        let
          packages = [
            pkgs-s.python3
            pkgs-s.uv
          ];
        in
        {
          os.environment.systemPackages = packages;
          hm = {
            home.packages = packages;
            programs.vscode.my.python = true;
          };
        }
      ))
      (lib.mkIf cfg.nixos.enable (
        lib.mkMerge (
          let
            nixos-editor = pkgs-o.nixos-editor.override {
              run = "code --wait --new-window ~/NixOS";
            };
          in
          [
            (
              let
                packages = [
                  pkgs-s.nix-index
                  pkgs-o.nix-update
                ];
              in
              lib-o.mkConfig {
                os.environment.systemPackages = packages;
                hm.home.packages = packages ++ [
                  nixos-editor
                ];
              }
            )
            (lib-o.mkIf cfg.nixos.startup {
              hm.my.wm.niri = {
                startups = ''
                  ${config.my.wm.niri.run-visible} "${lib.getExe nixos-editor}:code"
                '';
                workspaces = lib.mkOrder 900 ''
                  workspace "nixos" {
                      open-on-output "${osConfig.my.wm.niri.display.first}"
                  }
                '';
              };
            })
          ]
        )
      ))
    ]
  );
}
