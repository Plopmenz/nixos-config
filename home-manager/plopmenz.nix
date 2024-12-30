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
    ];
    sessionVariables = {
      RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    };
  };

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
