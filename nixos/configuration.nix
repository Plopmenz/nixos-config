# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        flake-registry = "";
        nix-path = config.nix.nixPath;

        substituters = [ "https://nix-community.cachix.org" ];
        trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
      };
      optimise.automatic = true;
      channel.enable = false;

      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

      gc = {
        automatic = true;
        options = "--delete-older-than 1d";
      };
    };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    backupFileExtension = "hmbackup";
    users = {
      plopmenz = import ../home-manager/plopmenz.nix;
    };
  };

  networking.hostName = "plopmenzPC"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  # networking.networkmanager.enable = true;
  networking = {
    useDHCP = false;
    useNetworkd = true;
    wireless.iwd = {
      enable = true;
      settings = {
        DriverQuirks = {
          DefaultInterface = "*";
        };
        Scan = {
          DisablePeriodicScan = true;
        };
      };
    };
  };

  systemd.network = {
    enable = true;
    wait-online = {
      timeout = 10;
      anyInterface = true;
    };
    networks = {
      "wired" = {
        matchConfig.Name = "en*";
        networkConfig = {
          DHCP = "yes";
        };
        dhcpV4Config.RouteMetric = 100;
        dhcpV6Config.WithoutRA = "solicit";
      };
      "wireless" = {
        matchConfig.Name = "wl*";
        networkConfig = {
          DHCP = "yes";
        };
        dhcpV4Config.RouteMetric = 200;
        dhcpV6Config.WithoutRA = "solicit";
      };
      "80-container-vz" = {
        matchConfig = {
          Kind = "bridge";
          Name = "vz-*";
        };
        networkConfig = {
          Address = "192.168.0.0/16";
          LinkLocalAddressing = "yes";
          DHCPServer = "no";
          IPMasquerade = "both";
          LLDP = "yes";
          EmitLLDP = "customer-bridge";
          IPv6AcceptRA = "no";
          IPv6SendRA = "yes";
        };
      };
    };
  };

  services.resolved.enable = false;
  services.dnsmasq = {
    enable = true;
    settings =
      {
        server = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        domain-needed = true;
        bogus-priv = true;
        no-resolv = true;
        cache-size = 1000;
        dhcp-range = [
          "192.168.0.0,192.168.255.255,255.255.0.0,24h"
        ];
        expand-hosts = true;
        local = "/container/";
        domain = "container";
      }
      // {
        dhcp-host = "192.168.91.1";
        address = [
          "/xnode.local/192.168.91.1"
        ];
      };
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Hyprland
  programs.dconf.enable = true;

  security.pam.services.hyprlock = { };

  services.greetd =
    let
      tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
      hyprland-session = "${pkgs.hyprland}/share/wayland-sessions";
    in
    {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --remember  --remember-session --asterisks --time  --greeting \"Welcome to PlopmenzOS!\" --sessions ${hyprland-session}";
        };
      };
    };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # GPU
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt
      rocmPackages.clr.icd
    ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.plopmenz = {
    initialPassword = "plopmenz";
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    pkgs.age
    pkgs.kitty
    pkgs.brightnessctl
    pkgs.intel-gpu-tools
  ];

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "plopmenz" ];

  programs.droidcam.enable = true;

  programs.steam.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  environment.shellAliases = {
    sysrebuild = "sudo nixos-rebuild switch --flake /etc/nixos/#plopmenzPC";
    sysupdate = "sudo nix flake update --flake /etc/nixos";
    sysedit = "sudo nano /etc/nixos/nixos/configuration.nix";
    sysflake = "sudo nano /etc/nixos/flake.nix";
  };

  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # systemd.services.create-hotspot = {
  #   wantedBy = [ "iwd.service" ];
  #   description = "Create hotspot (AP) virtual interface";
  #   serviceConfig = {
  #     Type = "oneshot";
  #   };
  #   path = [
  #     pkgs.iw
  #     pkgs.iproute2
  #   ];
  #   preStart = ''
  #     iw ap0 del || true
  #   '';
  #   script = ''
  #     iw phy0 interface add ap0 type __ap
  #     ip addr add 192.168.91.1/24 dev ap0
  #   '';
  # };

  # services.avahi = {
  #   enable = true;
  #   publish = {
  #     enable = true;
  #     addresses = true;
  #   };
  # };

  # networking.firewall.allowedUDPPorts = [
  #   53
  #   67
  # ];

  # sudo iwctl station wlan0 disconnect
  # sudo iwctl ap ap0 start "PlopmenzAP" "12345678"
  # sudo iwctl station wlan0 get-networks
  # sudo iwctl station wlan0 scan
  # sudo iwctl ap ap0 stop
  # sudo iwctl station wlan0 connect FatHamster --passphrase cicuta04
}
