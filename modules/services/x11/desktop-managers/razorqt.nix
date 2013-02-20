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

    services.xserver.desktopManager.session = singleton
      { name = "razorqt";
        bgSupport = true;
        start =
          ''
            exec ${pkgs.stdenv.shell} ${pkgs.razorqt}/bin/startrazor
          '';
      };

    # TODO: figure out what is needed here (and what not)
    # Seems we need to include at least razor-qt and a window manager
    # Openbox is the "official" window manager of razor-qt (although many work)
    # TODO: put the path to openbox in ~/.config/razor/session.conf (or actually,
    # the corresponding *global* config file).
    environment.systemPackages =
      [ pkgs.hicolor_icon_theme
        pkgs.shared_mime_info
        pkgs.razorqt
        pkgs.openbox
      ];

    environment.pathsToLink =
      [ "/share/themes" "/share/mime" "/share/desktop-directories" ];

    # Enable helpful DBus services.
    services.udisks.enable = true;
    services.upower.enable = config.powerManagement.enable;

  };

}
