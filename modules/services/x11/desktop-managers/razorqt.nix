{ config, pkgs, ... }:

with pkgs.lib;

let

  xcfg = config.services.xserver;
  cfg = xcfg.desktopManager.razorqt;

in

{
  options = {

    services.xserver.desktopManager.razorqt.enable = mkOption {
      default = false;
      example = true;
      description = "Enable the Razor-qt desktop environment.";
    };

  };


  config = mkIf (xcfg.enable && cfg.enable) {

    environment.etc =
      [
        # TODO: We want the WM to be configurable. How?
        { source = pkgs.writeText "session.conf"
            ''
              [General]
              windowmanager=${pkgs.openbox}/bin/openbox
            '';
          target = "xdg/razor/session.conf";
        }
      ];

    services.xserver.desktopManager.session = singleton
      { name = "razorqt";
        bgSupport = true;
        start =
          ''
            exec ${pkgs.stdenv.shell} ${pkgs.razorqt}/bin/startrazor
          '';
      };

    # TODO: figure out what is needed here (and what not)
    environment.systemPackages =
      [ pkgs.hicolor_icon_theme
        pkgs.shared_mime_info
        pkgs.razorqt
        pkgs.openbox
        # Add some xfce apps since Razor-qt includes none
        pkgs.xfce.mousepad
        pkgs.xfce.ristretto
        pkgs.xfce.terminal
        pkgs.xfce.thunar
      ];

    environment.pathsToLink =
      [ "/share/themes" "/share/mime" "/share/desktop-directories" ];

    # Enable helpful DBus services.
    services.udisks.enable = true;
    services.upower.enable = config.powerManagement.enable;

  };

}
