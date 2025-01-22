{ inputs, lib, config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;

  home = {
    username = "plopmenz";
    homeDirectory = "/home/plopmenz";
    shellAliases = {
      useredit = "sudo nano /etc/nixos/home-manager/plopmenz.nix";
      secretedit = "nix-shell -p sops --run 'cd /etc/nixos && sops secrets/plopmenz.yaml'";
    };
    packages = [
      pkgs.nodejs_22
      pkgs.bun
      pkgs.gcc
      pkgs.cargo
      pkgs.rustc
      pkgs.rustfmt
      pkgs.clippy
      pkgs.nixpkgs-fmt

      pkgs.font-awesome
      (pkgs.nerdfonts.override { fonts = [ "SpaceMono" ]; })

      pkgs.hyprshot
      pkgs.pavucontrol
      pkgs.networkmanager

      pkgs.libreoffice
      pkgs.gimp

      pkgs.discord
      pkgs.telegram-desktop
    ];
    sessionVariables = {
      RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    };
  };

  # start window manager
  programs.kitty.enable = true;
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$terminal" = "kitty";
    "$mod" = "SUPER";

    monitor = [
      ",prefered,auto,1"
    ];

    xwayland = {
      force_zero_scaling = true;
    };

    general = {
      border_size = 0;
      gaps_in = 0;
      gaps_out = 0;
      layout = "dwindle";
      allow_tearing = true;
    };

    input = {
      kb_layout = "us";
      follow_mouse = true;
      touchpad = {
        natural_scroll = true;
      };
      accel_profile = "flat";
      sensitivity = 0;
    };

    decoration = {
      rounding = 5;
      inactive_opacity = 0.9;
      blur.enabled = false;
      drop_shadow = false;
    };

    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
    };

    bind = [
      # General
      "$mod, return, exec, $terminal"
      "$mod SHIFT, q, killactive"
      "$mod SHIFT, e, exit"
      "$mod SHIFT, l, exec, ${pkgs.hyprlock}/bin/hyprlock"

      # Workspaces
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"

      "$mod, left, exec, hyprland-relative-workspace b"
      "$mod, right, exec, hyprland-relative-workspace f"

      # Move to workspaces
      "$mod SHIFT, 1, movetoworkspace,1"
      "$mod SHIFT, 2, movetoworkspace,2"
      "$mod SHIFT, 3, movetoworkspace,3"
      "$mod SHIFT, 4, movetoworkspace,4"
      "$mod SHIFT, 5, movetoworkspace,5"
      "$mod SHIFT, 6, movetoworkspace,6"
      "$mod SHIFT, 7, movetoworkspace,7"
      "$mod SHIFT, 8, movetoworkspace,8"
      "$mod SHIFT, 9, movetoworkspace,9"
      "$mod SHIFT, 0, movetoworkspace,10"

      # Applications
      "$mod ALT, b, exec, brave"

      # Brightness
      ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 2%-"
      ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl s +2%"

      # Screenshot
      ", Print, exec, hyprshot -m region --clipboard-only"
      "SHIFT, Print, exec, hyprshot -m window --clipboard-only"
    ];

    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    gestures = {
      workspace_swipe = true;
    };

    workspace = [
      "1, on-created-empty: brave"
      "2, on-created-empty: code"
      "3, on-created-empty: discord"
      "4, on-created-empty: telegram-desktop"
    ];

    windowrulev2 = [
      "float, class:^(pavucontrol)$"
      "size 700 700, class:^(pavucontrol)$"
      "float, class:^(nmtui)$"
      "size 700 700, class:^(nmtui)$"
    ];
  };

  home.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.waybar.enable = true;
  programs.waybar.settings = [
    {
      layer = "top";
      position = "top";
      spacing = 4;
      modules-left = [
        "image#os"
        "hyprland/workspaces"
      ];
      modules-center = [
        "hyprland/window"
      ];
      modules-right = [
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "temperature"
        "battery"
        "clock"
      ];

      "image#os" = {
        path = "/etc/nixos/assets/plopmenz.svg";
        size = 25;
        tooltip = false;
        on-click = "poweroff";
        on-click-right = "reboot";
      };

      "hyprland/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        warp-on-scroll = false;
        format = "{name}";
        format-icons = {
          urgent = "";
          active = "";
          default = "";
        };
      };
      "pulseaudio" = {
        format = "{icon}  {volume}%";
        format-bluetooth = "{icon}  {volume}%    {format_source}";
        format-bluetooth-muted = "  {icon}    {format_source}";
        format-muted = "  {format_source}";
        format-source = "  {volume}%";
        format-source-muted = "";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [ "" "" "" ];
        };
        on-click = "pavucontrol";
      };
      "network" = {
        format-wifi = "   {essid} ({signalStrength}%)";
        format-ethernet = "{ipaddr}/{cidr} ";
        tooltip-format = "{ifname} via {gwaddr} ";
        format-linked = "{ifname} (No IP) ";
        format-disconnected = "Disconnected ⚠";
        on-click = "kitty --class nmtui nmtui";
      };
      "cpu" = {
        format = "  {usage}%";
        tooltip = true;
      };
      "memory" = {
        format = "  {}%";
        tooltip = true;
      };
      "temperature" = {
        interval = 10;
        hwmon-path = "/sys/devices/platform/coretemp.0/hwmon/hwmon3/temp1_input";
        critical-threshold = 100;
        format-critical = " {temperatureC}";
        format = " {temperatureC}°C";
      };
      "battery" = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon}   {capacity}%";
        format-full = "{icon}   {capacity}%";
        format-charging = " {capacity}%";
        format-plugged = " {capacity}%";
        format-alt = "{time}   {icon}";
        format-icons = [ "" "" "" "" "" ];
      };
      "clock" = {
        format = "{:%H:%M | %e %B} ";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        format-alt = "{:%Y-%m-%d}";
      };
    }
  ];
  programs.waybar.style = ''
    * {
      /* `otf-font-awesome` and SpaceMono Nerd Font are required to be installed for icons */
      font-family: "Fira Sans Semibold", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
      font-size: 15px;
      transition: background-color .3s ease-out;
    }

    window#waybar {
      background: rgba(26, 27, 38, 0.75);
      color: #c0caf5;
      font-family: 
        SpaceMono Nerd Font,
        feather;
      transition: background-color .5s;
    }

    .modules-left,
    .modules-center,
    .modules-right
    {
      background: rgba(0, 0, 8, .7);
      margin: 5px 10px;
      padding: 0 5px;
      border-radius: 15px;
    }
    .modules-left {
      padding: 0;
    }
    .modules-center {
      padding: 0 10px;
    }

    #clock,
    #battery,
    #cpu,
    #memory,
    #disk,
    #temperature,
    #backlight,
    #network,
    #pulseaudio,
    #wireplumber,
    #custom-media,
    #tray,
    #mode,
    #scratchpad,
    #power-profiles-daemon,
    #mpd {
      padding: 0 10px;
      border-radius: 15px;
    }

    #clock:hover,
    #battery:hover,
    #cpu:hover,
    #memory:hover,
    #disk:hover,
    #temperature:hover,
    #backlight:hover,
    #network:hover,
    #pulseaudio:hover,
    #wireplumber:hover,
    #custom-media:hover,
    #tray:hover,
    #mode:hover,
    #scratchpad:hover,
    #power-profiles-daemon:hover,
    #mpd:hover {
      background: rgba(26, 27, 38, 0.9);
    }


    #workspaces button {
      background: transparent;
      font-family:
        SpaceMono Nerd Font,
        feather;
      font-weight: 900;
      font-size: 13pt;
      color: #c0caf5;
      border:none;
      border-radius: 15px;
    }

    #workspaces button.active {
      background: #13131d; 
    }

    #workspaces button:hover {
      background: #11111b;
      color: #cdd6f4;
      box-shadow: none;
    }

    #image.os {
      margin-left: 10px;
      padding: 2px 0px;
    }
  '';
  programs.waybar.systemd.enable = true;
  # end window manager

  # start dark mode
  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.libsForQt5.breeze-gtk;
    };
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  qt = {
    enable = true;
    platformTheme = {
      name = "gtk";
    };
    style = {
      name = "gtk2";
      package = pkgs.libsForQt5.breeze-qt5;
    };
  };
  # end dark mode

  programs.home-manager.enable = true;
  programs.bash.enable = true; # required to generate shell aliases
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    userName = "Plopmenz";
    userEmail = "plopmenz@gmail.com";
    lfs.enable = true;
    extraConfig = {
      github.user = "Plopmenz";
      hub.protocol = "ssh";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      url."git@github.com:".insteadOf = [
        "https://github.com/"
        "github:"
      ];
    };
  };

  programs.brave = {
    enable = true;
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      streetsidesoftware.code-spell-checker
      visualstudioexptteam.vscodeintellicode
      visualstudioexptteam.intellicode-api-usage-examples
      esbenp.prettier-vscode

      ms-azuretools.vscode-docker
      tamasfe.even-better-toml
      ms-vscode.makefile-tools
      jnoortheen.nix-ide
      redhat.vscode-xml

      golang.go
      rust-lang.rust-analyzer
      #juanblanco.solidity
      bradlc.vscode-tailwindcss
    ];
    userSettings = {
      "editor.formatOnSave" = true;
    };
  };

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "24.05";
}
