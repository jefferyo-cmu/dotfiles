{ pkgs, lib, config, inputs, neovim-nightly-overlay, ...}:

{
  imports = [ inputs.ragenix.homeManagerModules.default ];

  nixpkgs.config.allowUnfreePredicate = pkg : builtins.elem (lib.getName pkg) [
    "discord-canary"
    "steam"
    "steam-unwrapped"
    "cloudflare-warp"
    "ltspice"
    "7zz"
    "uasm"
  ];

  home.packages = with pkgs; [
    # System utilities
    appimage-run
    android-tools

    # System components
    libnotify
    nerd-fonts.fira-code
    vulkan-tools
    mesa-demos

    # Hyprland components
    hyprshot
    wl-clipboard
    cliphist
    zoxide
    _7zz-rar
    mpv
    imv

    # Languages
    python312
    rustup
    nushell
    gcc
    gnumake

    # EDA
    verilator
    kicad
    ltspice
    gtkwave

    # Apps
    discord-canary
    signal-desktop
    xournalpp
    tmux
    keepassxc
    typst
    deluge
    cloudflare-warp
    amberol
    
    # Gaming
    steam
    protonup-rs
    prismlauncher
    limo
    dolphin-emu
    ryubing
    azahar
    openmw

    # Gaming components
    gamemode
  ];

  fonts.fontconfig.enable = true;

  programs.firefox = {
    enable = true;
    profiles.default = {
      # extensions.force = true;
      settings = {
      	"layout.css.devPixelsPerPx" = "1.2";
      };
    };
    policies = {
      ExtensionSettings = {
        # "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
      	# uBlock Origin:
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
      	# Privacy Badger:
        "jid1-MnnxcxisBPnSXQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4638816/privacy_badger17-2025.12.9.xpi";
          installation_mode = "force_installed";
        };
      	# User-Agent Switcher and Manager:
        "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4593736/user_agent_string_switcher-0.6.6.xpi";
          installation_mode = "force_installed";
        };
      	# ClearURLs:
        "{74145f27-f039-47ce-a470-a662b129930a}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4432106/clearurls-1.27.3.xpi";
          installation_mode = "force_installed";
        };
      	# SponsorBlock:
        "sponsorBlocker@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4644570/sponsorblock-6.1.2.xpi";
          installation_mode = "force_installed";
        };
      	# Decentraleyes:
        "jid1-BoFifL9Vbdl2zQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4392113/decentraleyes-3.0.0.xpi";
          installation_mode = "force_installed";
        };
      	# Disconnect:
        "2.0@disconnect.me" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4240055/disconnect-20.3.1.2.xpi";
          installation_mode = "force_installed";
        };
      	# Don't Track Me Google:
        "dont-track-me-google@robwu.nl" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4132891/dont_track_me_google1-4.28.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    dotDir = "${config.xdg.configHome}/zsh";

    shellAliases = {
      update = "nh os switch";

      config = "nvim ~/dotfiles/configuration.nix";
      flake = "nvim ~/dotfiles/flake.nix";
      home = "nvim ~/dotfiles/home.nix";	  
      hypr = "nvim ~/.config/hypr/hyprland.conf";	  

      trash-clear = "rm -rf ~/.local/share/Trash/files/* && rm -rf ~/.local/share/Trash/info/*";
      
      sudo = "run0";
      ls = "eza -la";
      cat = "bat --style=plain --paging=never";
      cd = "z";
      claer = "clear";
    };

    oh-my-zsh = {
      enable = true;
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    plugins = {
      starship = pkgs.fetchFromGitHub {
        owner = "Rolv-Apneseth";
        repo = "starship.yazi";
        rev = "a63550b2f91f0553cc545fd8081a03810bc41bc0";
        sha256 = "sha256-PYeR6fiWDbUMpJbTFSkM57FzmCbsB4W4IXXe25wLncg=";  
      };
    };

    initLua = ''
      require("starship"):setup()
    '';
  };
  
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_age" ];

  age.secrets.afs_password = {
    file = ./secrets/afs_password.age;
  };

  programs.rclone = {
    enable = true;
    remotes = {
      afs = {
        # Wrap the standard rclone keys in a 'config' block
        config = {
          type = "sftp";
          host = "ece026.ece.local.cmu.edu";
          user = "jefferyo";
          key_file = "none";
          auth_method = "password";
          shell_type = "unix";
        };
      };
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Jeffery Oo";
        email = "oojefferywm@proton.me";
      };
      pull.rebase = false;
      init.defaultBranch = "main";
      tag.gpgSign = true;
    };
    signing = {
      format = "openpgp";
      key = "19992BECE706CC59";
      signByDefault = true;
    };
  };

  programs.neovim = {
    enable = true;
    package = neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
    
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;

    plugins = with pkgs.vimPlugins; [
      telescope-nvim
      telescope-zoxide
      telescope-undo-nvim

      luasnip
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp_luasnip

      typst-preview-nvim

      (nvim-treesitter.withPlugins (p: [
      	p.systemverilog
      	p.vhdl
      	p.asm
        p.rust
      	p.c
      	p.arduino
      	p.matlab
      	p.nix
      	p.lua
      	p.luadoc
      	p.java
      	p.javadoc
      	p.python
      	p.yaml
      	p.json
        p.typst
      ]))
    ];

    extraPackages = with pkgs; [
      verible
      vhdl-ls
      asm-lsp
      rust-analyzer
      clang-tools
      arduino-language-server
      nil
      lua-language-server
      jdt-language-server
      pyright
      yaml-language-server
      vscode-langservers-extracted
      tinymist
    ];

    initLua = builtins.readFile ./neovim.lua;
  };

  catppuccin = {
    autoEnable = true;
    enable = true;
    flavor = "mocha";

    firefox.enable = false;
    eza.enable = true;
    yazi.enable = true;
    nvim.enable = true;
    atuin.enable = true;
    starship.enable = true;
    hyprland.enable = true;
    bat.enable = true;
    foot.enable = true;
    rofi.enable = true;
    dunst.enable = true;
    waybar.enable = true;
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "FiraCode Nerd Font:size=11";
      };
    };
  };

  programs.bat.enable = true;
  programs.rofi.enable = true;
  services.dunst.enable = true;

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  services.ssh-agent.enable = false;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks."*" = {
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
      addKeysToAgent = "yes";
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  home.file.".local/share/wayland-sessions/hyprland-uwsm.desktop".text = lib.mkForce ''
[Desktop Entry]
Name=Hyprland (uwsm-managed)
Comment=An intelligent dynamic tiling Wayland compositor
Exec=uwsm start -e -D Hyprland hyprland.desktop
TryExec=uwsm
DesktopNames=Hyprland:X-NIXOS-SYSTEMD-AWARE
Type=Application
  '';

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  home.sessionVariables = {
    GTK_USE_PORTAL = "1"; # legacy
    QT_QPA_PLATFORMTHEME = "xdgdesktopportal";

    FLAKE="$HOME/dotfiles";

    # XDG_DATA_DIRS = lib.concatStringsSep ":" [
    #   "$HOME/.local/share/flatpak/exports/share"
    #   "/var/lib/flatpak/exports/share"
    #   "$HOME/.nix-profile/share"
    #   "/run/current-system/sw/share"
    # ];
  };

  home.stateVersion = "25.05";
}

