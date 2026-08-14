# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(6) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs,... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.spicetify-nix.nixosModules.default
    ];

  # Bootloader.

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  #swap y zram
  zramSwap = {
    enable = true;
    memoryPercent = 50; # Cambia este porcentaje si 50% es más o menos de 4GB según tu RAM total
    algorithm = "zstd";
  };

  # Configuración de Swap 
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4096; # 4096 MB = 4 GB
    }
  ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Tegucigalpa";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_HN.UTF-8";
    LC_IDENTIFICATION = "es_HN.UTF-8";
    LC_MEASUREMENT = "es_HN.UTF-8";
    LC_MONETARY = "es_HN.UTF-8";
    LC_NAME = "es_HN.UTF-8";
    LC_NUMERIC = "es_HN.UTF-8";
    LC_PAPER = "es_HN.UTF-8";
    LC_TELEPHONE = "es_HN.UTF-8";
    LC_TIME = "es_HN.UTF-8";
  };
#services
#pipewire
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
  wireplumber.enable = true;
};
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "latam";
    variant = "nodeadkeys";
  };
#services custom
 services.greetd = {
  enable = true;
  settings = {
    default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%H:%M | %Y-%m-%d' --remember --remember-session --sessions ${pkgs.swayfx}/share/wayland-sessions:${pkgs.niri}/share/wayland-sessions";
      user = "greeter";
    };
  };
};

# Evitar que la TTY parpadee o interfiera con greetd al arrancar
systemd.services.greetd.serviceConfig = {
  Type = "idle";
  StandardInput = "tty";
  StandardOutput = "tty";
  StandardError = "journal";
  TTYReset = "yes";
  TTYVHangup = "yes";
  TTYVTDisallocate = "yes";
};
# Configure console keymap
  console.keyMap = "la-latin1";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."polla" = {
    isNormalUser = true;
    description = "nixosbtw";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
    btop
    localsend
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  git
  neovim
  fastfetch
  lavat
  sl
  cowsay
  python3
  thunar
  flatpak
  pkgs.librewolf
  coreutils
  gnused
  gnugrep
  xwayland-satellite
  xwayland
  papirus-icon-theme
  nerd-fonts.jetbrains-mono
  posy-cursors
  xfconf
  pavucontrol
  glib
  ffmpeg
  mpv
  yt-dlp
  curl
  fzf
  patch
  vesktop
  kitty
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.niri.enable = true;
  programs.steam.enable = true;
  programs.obs-studio.enable = true;
  #config thunar
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];
programs.spicetify =
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  enable = true;

  enabledExtensions = with spicePkgs.extensions; [
    adblock
    hidePodcasts
    shuffle # shuffle+ (special characters are sanitized out of extension names)
  ];
  enabledCustomApps = with spicePkgs.apps; [
    newReleases
    ncsVisualizer
  ];
  enabledSnippets = with spicePkgs.snippets; [
    rotatingCoverart
    pointer
  ];
  };
#xdg
  #config LARGUISIMA (zsh, si me cambie :v)
 programs.zsh = {
  enable = true;
  shellAliases = {
    ls = "ls --color=auto";
    grep = "grep --color=auto";
    fgrep = "fgrep --color=auto";
    egrep = "egrep --color=auto";
    diff = "diff --color=auto";
    ip = "ip --color=auto";
  };
};
# programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable
    hardware.bluetooth.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
    hardware.graphics = {
    enable = true;
    enable32Bit = true;
    };
    hardware.pulseaudio.enable = false;

    services.flatpak.enable = true;
    systemd.services.flatpak-repo = {
  wantedBy = [ "multi-user.target" ];
  path = [ pkgs.flatpak ];
  script = ''
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  '';
};
  services.tumbler.enable = true;
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
  system.stateVersion = "26.05"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
#configs extra
security.polkit.enable = true;
# borra generaciones viejas y optimiza el almacenamiento automáticamente
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  # evita que se congele el sistema si te quedas sin ram
  systemd.oomd.enable = true;
  # prioriza la ram física y zram antes de tocar el disco
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };
  # para que las ventanas abran al instante y no sufran delay al arrancar
services.xserver.enable = false; # asegúrate de no tener esto si usas Wayland puro
programs.dconf.enable = true; # vital para que los temas y apps gráficas no esperen timeouts de dbus
security.rtkit.enable = true; # prioridad de audio y hilos para que el sistema no se trabe en procesos gráficos
services.dbus.implementation = "broker"; # reemplaza dbus-daemon por dbus-broker (mucho más rápido y eficiente)

}


