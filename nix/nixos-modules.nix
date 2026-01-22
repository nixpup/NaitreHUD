self: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.naitre;
in {
  options = {
    programs.naitre = {
      enable = lib.mkEnableOption "naitre, a wayland compositor based on dwl";
      package = lib.mkOption {
        type = lib.types.package;
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.naitre;
        description = "The naitre package to use";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      [
        cfg.package
      ]
      ++ lib.optional true pkgs.wofi;

    xdg.portal = {
      enable = lib.mkDefault true;

      config = {
        naitre = {
          default = [
            "gtk"
          ];
          # except those
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
          "org.freedesktop.impl.portal.ScreenShot" = ["wlr"];

          # wlr does not have this interface
          "org.freedesktop.impl.portal.Inhibit" = [];
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];

      wlr.enable = lib.mkDefault true;

      configPackages = [cfg.package];
    };

    security.polkit.enable = lib.mkDefault true;

    programs.xwayland.enable = lib.mkDefault true;

    services = {
      displayManager.sessionPackages = [cfg.package];

      graphical-desktop.enable = lib.mkDefault true;
    };
  };
}
