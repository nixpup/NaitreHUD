self: {
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.wayland.windowManager.naitre;
  variables = lib.concatStringsSep " " cfg.systemd.variables;
  extraCommands = lib.concatStringsSep " && " cfg.systemd.extraCommands;
  systemdActivation = ''${pkgs.dbus}/bin/dbus-update-activation-environment --systemd ${variables}; ${extraCommands}'';
  autostart_sh = pkgs.writeShellScript "autostart.sh" ''
    ${lib.optionalString cfg.systemd.enable systemdActivation}
    ${cfg.autostart_sh}
  '';
  exit_script_wofi = pkgs.writeShellScript "naitre-exit.sh" ''
    #!/usr/bin/env sh

    pid=$(pidof naitre)
    choice=$(printf "Yes\nNo" | wofi --dmenu \
      --prompt "Exit NaitreHUD?" \
      --width 300 \
      --height 150)

    if [ "$choice" = "Yes" ] && [ -n "$pid" ]; then
        kill "$pid"
    fi
  '';
  exit_script_vicinae = pkgs.writeShellScript "naitre-exit.sh" ''
    #!/usr/bin/env sh

    pid=$(pidof naitre)
    choice=$(printf 'Yes\nNo' | vicinae dmenu --placeholder "Exit NaitreHUD?")

    if [ "$choice" = "Yes" ] && [ -n "$pid" ]; then
        kill "$pid"
    fi
  '';
  exit_script = if cfg.scripts.exit.launcher == "wofi" then exit_script_wofi else exit_script_vicinae;
  vicinae_dmenu_run_script = pkgs.writeShellScript "vicinae-dmenu-run.sh" ''
    #!/usr/bin/env bash

    compgen -c | sort -u | vicinae dmenu --placeholder "Run" | sh
  '';
  pavucontrol_script = pkgs.writeShellScript "pavucontrol.sh" ''
    #!/usr/bin/env bash

    GSK_RENDERER=gl pavucontrol
  '';
in {
  options = {
    wayland.windowManager.naitre = with lib; {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      extraPackages = mkOption {
        type = types.listOf types.package;
        default = [];
        example = [ pkgs.wofi ];
        description = "Extra packages to install alongside Naitre HUD";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.naitre;
        description = "The naitre package to use";
      };
      systemd = {
        enable = mkOption {
          type = types.bool;
          default = pkgs.stdenv.isLinux;
          example = false;
          description = ''
            Whether to enable {file}`naitre-session.target` on
            naitre startup. This links to
            {file}`graphical-session.target`.
            Some important environment variables will be imported to systemd
            and dbus user environment before reaching the target, including
            * {env}`DISPLAY`
            * {env}`WAYLAND_DISPLAY`
            * {env}`XDG_CURRENT_DESKTOP`
            * {env}`XDG_SESSION_TYPE`
            * {env}`NIXOS_OZONE_WL`
            You can extend this list using the `systemd.variables` option.
          '';
        };
        variables = mkOption {
          type = types.listOf types.str;
          default = [
            "DISPLAY"
            "WAYLAND_DISPLAY"
            "XDG_CURRENT_DESKTOP"
            "XDG_SESSION_TYPE"
            "NIXOS_OZONE_WL"
            "XCURSOR_THEME"
            "XCURSOR_SIZE"
          ];
          example = ["--all"];
          description = ''
            Environment variables imported into the systemd and D-Bus user environment.
          '';
        };
        extraCommands = mkOption {
          type = types.listOf types.str;
          default = [
            "systemctl --user reset-failed"
            "systemctl --user start naitre-session.target"
          ];
          description = ''
            Extra commands to run after D-Bus activation.
          '';
        };
        xdgAutostart = mkEnableOption ''
          autostart of applications using
          {manpage}`systemd-xdg-autostart-generator(8)`
        '';
      };
      settings = mkOption {
        description = "naitre config content";
        type = types.lines;
        default = "";
        example = ''
          # menu and terminal
          bind=Alt,space,spawn,rofi -show drun
          bind=Alt,Return,spawn,foot
        '';
      };
      modularize = {
        enable = mkOption {
          description = "Enable modularized Config";
          type = types.bool;
          default = false;
          example = true;
        };
        config = mkOption {
          description = "Modularize Config.conf";
          type = types.lines;
          default = ''
            #--------#
            # Source #
            #--------#
            # Generated Configs
            ${lib.optionalString cfg.scripts.pavucontrol.enable "source=~/.config/naitre/pavucontrol.conf"}
            ${lib.optionalString cfg.scripts.vicinaeDmenuRun.enable "source=~/.config/naitre/vicinae-dmenu-run.conf"}
            ${lib.optionalString cfg.scripts.exit.enable "source=~/.config/naitre/exit.conf"}
            # User Config
            source=~/.config/naitre/main.conf
          '';
          example = ''
            #--------#
            # Source #
            #--------#
            # User Config
            source=~/.config/naitre/main.conf
          '';
        };
        additional = mkOption {
          description = "Additional Lines for the Config.conf";
          type = types.lines;
          default = "";
          example = ''
            #------------#
            # Additional #
            #------------#
            # Exec
            exec-once=wl-paste --watch cliphist store

            # Env
            env=WINDOW_MANAGER,naitre

            # Input
            xkb_rules_layout=us(altgr-intl)
          '';
        };
      };
      autostart_sh = mkOption {
        description = "WARNING: This is a shell script, but no need to add a shebang.";
        type = types.lines;
        default = "";
        example = ''
          waybar &
        '';
      };
      scripts = {
        exit = {
          enable = mkOption {
            description = "Create Exit Script";
            type = types.bool;
            default = true;
            example = true;
          };
          launcher = mkOption {
            description = "Pick the default launcher for the Exit Script";
            type = types.enum [ "vicinae" "wofi" ];
            default = "vicinae";
          };
          keybind = mkOption {
            type = types.str;
            default = "Alt+Shift,x";
            example = "SUPER,x";
            description = "Keybind for the Exit Config Action";
          };
        };
        pavucontrol = {
          enable = mkOption {
            description = "Pavucontrol Launch Script";
            type = types.bool;
            default = false;
            example = true;
          };
          keybind = mkOption {
            type = types.str;
            default = "SUPER,a";
            example = "Alt,u";
            description = "Keybind for the Pavucontrol Config Action";
          };
        };
        vicinaeDmenuRun = {
          enable = mkOption {
            description = "Vicinae dmenu_run-like Script";
            type = types.bool;
            default = false;
            example = true;
          };
          keybind = mkOption {
            type = types.str;
            default = "SUPER,f";
            example = "Alt,g";
            description = "Keybind for the Vicinae Dmenu Run Config Action";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ]
    ++ cfg.extraPackages
    ++ lib.optional (cfg.scripts.exit.enable && cfg.scripts.exit.launcher == "wofi") pkgs.wofi;
    xdg.configFile = {
      "naitre/${if cfg.modularize.enable then "main.conf" else "config.conf"}" = lib.mkIf (cfg.settings != "") {
        text = cfg.settings;
      };
      "naitre/autostart.sh" = lib.mkIf (cfg.autostart_sh != "") {
        source = autostart_sh;
        executable = true;
      };
    };
    systemd.user.targets.naitre-session = lib.mkIf cfg.systemd.enable {
      Unit = {
        Description = "naitre compositor session";
        Documentation = ["man:systemd.special(7)"];
        BindsTo = ["graphical-session.target"];
        Wants =
          [
            "graphical-session-pre.target"
          ]
          ++ lib.optional cfg.systemd.xdgAutostart "xdg-desktop-autostart.target";
        After = ["graphical-session-pre.target"];
        Before = lib.optional cfg.systemd.xdgAutostart "xdg-desktop-autostart.target";
      };
    };
    home.file = lib.mkMerge [
      (lib.mkIf cfg.modularize.enable {
        ".config/naitre/config.conf" = {
          text = cfg.modularize.config + lib.optionalString (cfg.modularize.additional != "") "\n${cfg.modularize.additional}";
        };
      })
      (lib.mkIf cfg.scripts.exit.enable {
        ".scripts/naitre-exit.sh" = {
          source = exit_script;
          executable = true;
        };
        ".config/naitre/exit.conf" = {
          text = ''
            # Include via: 'source=~/.config/naitre/exit.conf' in '~/.config/naitre/config.conf'.
            bind=${cfg.scripts.exit.keybind},spawn,~/.scripts/naitre-exit.sh
          '';
        };
      })
      (lib.mkIf cfg.scripts.pavucontrol.enable {
        ".scripts/pavucontrol.sh" = {
          source = pavucontrol_script;
          executable = true;
        };
        ".config/naitre/pavucontrol.conf" = {
          text = ''
            # Include via: 'source=~/.config/naitre/pavucontrol.conf' in '~/.config/naitre/config.conf'.
            bind=${cfg.scripts.pavucontrol.keybind},spawn,~/.scripts/pavucontrol.sh
          '';
        };
      })
      (lib.mkIf cfg.scripts.vicinaeDmenuRun.enable {
        ".scripts/vicinae-dmenu-run.sh" = {
          source = vicinae_dmenu_run_script;
          executable = true;
        };
        ".config/naitre/vicinae-dmenu-run.conf" = {
          text = ''
            # Include via: 'source=~/.config/naitre/vicinae-dmenu-run.conf' in '~/.config/naitre/config.conf'.
            bind=${cfg.scripts.vicinaeDmenuRun.keybind},spawn,~/.scripts/vicinae-dmenu-run.sh
          '';
        };
      })
    ];
  };
}
