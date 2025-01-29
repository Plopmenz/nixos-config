{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

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
      pkgs.nixfmt-rfc-style

      pkgs.font-awesome
      (pkgs.nerdfonts.override { fonts = [ "SpaceMono" ]; })

      pkgs.pcmanfm
      pkgs.hyprshot
      pkgs.pavucontrol
      pkgs.networkmanager

      pkgs.libreoffice
      pkgs.gimp

      pkgs.discord
      pkgs.telegram-desktop

      pkgs.postman
    ];
    sessionVariables = {
      RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    };
  };

  # start window manager
  programs.kitty.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
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
        shadow.enabled = false;
      };

      misc = {
        vfr = true;
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

        "$mod, left, workspace, -1"
        "$mod, right, workspace, +1"

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
        "$mod ALT, c, exec, code"
        "$mod, z, exec, rofi -show drun"

        # Brightness
        ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 2%-"
        ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl s +2%"

        # Screenshot
        ", Print, exec, hyprshot -m region --clipboard-only"
        "SHIFT, Print, exec, hyprshot -m window --clipboard-only"
        "SHIFT ALT, Print, exec, hyprshot -m output --clipboard-only"
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
      ];

      windowrulev2 = [
        "float, class:^(org.pulseaudio.pavucontrol)$"
        "size 700 700, class:^(org.pulseaudio.pavucontrol)$"
        "float, class:^(nmtui)$"
        "size 700 700, class:^(nmtui)$"
      ];

      exec-once = [
        "waybar"
        "dunst"
      ];
    };
  };

  home.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        spacing = 7;
        modules-left = [
          "image#os"
          "custom/os-name"
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
          path = "/etc/nixos/assets/plopmenz.png";
          size = 20;
          tooltip = false;
          on-click = "shutdown now"; # hyprctl --batch `hyprctl -j clients | jq -r '.[] | \"dispatch closewindow address:\(.address);\"'`
          on-click-middle = "reboot";
        };

        "custom/os-name" = {
          format = "PlopmenzOS";
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
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}%  {format_source}";
          format-bluetooth-muted = " {icon}  {format_source}";
          format-muted = " {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
        };
        "network" = {
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          on-click = "kitty --class nmtui nmtui";
        };
        "cpu" = {
          format = " {usage}%";
          tooltip = true;
        };
        "memory" = {
          format = " {}%";
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
          format = "{icon}  {capacity}%";
          format-full = "{icon}  {capacity}%";
          format-charging = "{capacity}%";
          format-plugged = " {capacity}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
        "clock" = {
          format = "{:%H:%M | %e %B} ";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d}";
        };
      }
    ];
    style = ''
      * {
        /* `otf-font-awesome` and SpaceMono Nerd Font are required to be installed for icons */
        min-height: 0;
        padding: 0;
        margin: 0;
        color: #c0caf5;
      }

      window#waybar {
        background: rgba(26, 27, 38, 0.75);
        font-family: 
          SpaceMono Nerd Font,
          feather;
        font-size: 12px;
      }

      .modules-left,
      .modules-center,
      .modules-right
      {
        background: rgba(0, 0, 8, .7);
        border-radius: 10px;
        padding: 2px 5px;
        margin: 2px 2px;
      }

      button {
        background: transparent;
      }

      button:hover {
        background: rgba(50, 50, 100, 1);
      }
    '';
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 1;
      };

      background = [
        {
          blur_passes = 3;
          blur_size = 3;
        }
      ];

      label = {
        text = "cmd[update:1000] echo \"$(date +\"%-I:%M\")\"";
        font_size = 95;
        font_family = "JetBrains Mono Bold";
        position = "0, 150";
        halign = "center";
        valign = "center";
      };

      input-field = [
        {
          size = "200, 75";
          position = "0, -80";
        }
      ];
    };
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "SpaceMono Nerd Font 12";
    extraConfig = {
      modi = "drun";
      show-icons = true;
      drun-display-format = "{icon} {name}";
      display-drun = "Launch App";
    };
    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        "*" = {
          background-color = mkLiteral "#24273A";
          text-color = mkLiteral "#c0caf5";
          border-color = mkLiteral "#c0caf5";
        };
        window.width = mkLiteral "30%";
        mainbox = {
          border = 1;
          padding = 2;
        };
        listview = {
          lines = 10;
          spacing = 5;
          padding = mkLiteral "5 0 0";
        };
        element.padding = 2;
        "element.selected".background-color = mkLiteral "#363A4F";
        element-text.background-color = mkLiteral "inherit";
        inputbar = {
          spacing = 5;
          padding = 2;
          border = mkLiteral "0 0 1";
          border-color = mkLiteral "#c0caf5";
        };
      };
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        font = "Monospace 8";
        background = "#000000";
        foreground = "#c0caf5";
        frame_color = "#c0caf5";
        frame_width = 2;
      };
    };
  };
  # end window manager

  # start dark mode
  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 11;
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
      github.vscode-github-actions

      golang.go
      rust-lang.rust-analyzer
      # juanblanco.solidity
      bradlc.vscode-tailwindcss
    ];
    userSettings = {
      "editor.formatOnSave" = true;
    };
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "24.05";
}
