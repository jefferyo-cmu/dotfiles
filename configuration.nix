# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_xanmod;

  hardware.firmware = [
    (pkgs.runCommand "sceptre-q32-edid" {} ''
      mkdir -p $out/lib/firmware/edid
      echo "AP///////wBOFMYMAQAAACgdAQOARih4K911pVVOnScLUFQjCABhQIHAgYCpwHFA0cABAQEBal4AoKCgKVAwIDUAxI4hAAAeAAAA/QAwQRdjHgAKICAgICAgAjqAGHE4LUBYLEUADyghAAAeAAAA/ABTY2VwdHJlIFEzMgogASoCAyrxSxAfBRQEEwMSAhEBIwkHB4MBAABoAwwAEAAAeABoGgAAAQEwPACORICgcDgtQFgsRQBVKCEAAB5mIVCwUQAbMEBwNgAPKCEAAB5/IVaqUQAeMEaPMwBVKCEAAH/TLACkUTgtQCCgNQBVKCEAAHsAAAAAAAAAAAAAAAAASg==" \
      | base64 -d > $out/lib/firmware/edid/sceptre-q32.bin
    '')
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [
    "hid_sony"
    "uinput"
  ];
  boot.kernelParams = [
    "amd_pstate=active"
    "drm.edid_firmware=HDMI-A-2:edid/sceptre-q32.bin"
  ];

  # RAM and Swap
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    "vm.max_map_count" = 2147483642;
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
  };
  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableUserSlices = true;
  };

  # CPU
  hardware.cpu.amd.updateMicrocode = true;
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu = {
    opencl.enable = true;
    initrd.enable = true;
  };
  systemd.tmpfiles.rules = 
  let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];
  services.lact = {
    enable = true;
  };

  networking.hostName = "yoops"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
  };
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22       # SSH
    8100     # BlueMap (Mineraft)
    25565    # Minecraft
    27036    # Steam (in-home streaming / Remote Play)
    27037    # Steam
    47984    # Sunshine (Moonlight HTTPS)
    47989    # Sunshine (Moonlight HTTP)
    48010    # Sunshine (Moonlight RTSP)
  ];

  networking.firewall.allowedUDPPorts = [
    27031    # Steam (Remote Play)
    27036    # Steam (Remote Play)
    47998    # Sunshine (Moonlight video)
    47999    # Sunshine (Moonlight control)
    48000    # Sunshine (Moonlight audio)
    48002    # Sunshine (Moonlight mic)
    48010    # Sunshine (Moonlight RTSP)
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };


  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspend=true;
    AllowHybridSleep=true;
  };

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="054c", MODE="0660", GROUP="input"
  '';

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = false;

  # Enable ly display manager
  services.displayManager.ly = {
    enable = true;
    settings = {
      waylandsessions = "/home/yoops/.local/share/wayland-sessions";
    };
  };

  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;
  };
  
  # Enable Tailscale and IP forwarding
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;
  };

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "3efa5cb78a624343" ];
  };

  systemd.services = {
    # Enable UDP GRO forwarding on boot
    tailscale-udp-gro = {
      description = "Enable UDP GRO forwarding for Tailscale";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        # Get the default route interface
        NETDEV=$(${pkgs.iproute2}/bin/ip -o route get 8.8.8.8 | cut -f 5 -d " ")
        if [ -n "$NETDEV" ]; then
          ${pkgs.ethtool}/bin/ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off || true
        fi
      '';
    };

    display-manager = {
      environment = {
        XDG_DATA_DIRS = "/run/current-system/sw/share";
      };
    };

    tailscaled = {
      after = [ "network-online.target" "NetworkManager-wait-online.service" ];
      wants = [ "network-online.target" "NetworkManager-wait-online.service" ];
    };

    NetworkManager-wait-online.enable = true;
  };

  programs.zsh.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 20";
    flake = "/home/yoops/dotfiles";
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    libxcrypt-legacy   # libcrypt.so.1 — tes3cmd needs this
    stdenv.cc.cc.lib   # libstdc++ / libgcc_s — common C++ runtime deps
    zlib               # libz.so.1
    glibc              # libm.so.6, libc.so.6, etc
  ];


  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };
  users.users.yoops = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "render" "input" "docker" ];
  };

  users.defaultUserShell = pkgs.zsh;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vulkan-validation-layers
    libva-utils
    desktop-file-utils
    steam-run

    rage
    ragenix
  ];

  environment.variables = {
    NIXOS_OZONE_WL = "1"; # Configure Electron / CEF apps to use Wayland

    RADV_PERFTEST="gpl";
    RADV_DEBUG="nongg";
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

