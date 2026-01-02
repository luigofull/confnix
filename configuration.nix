{ config, pkgs, inputs, ... }:

{
  imports = [
      ./hardware-configuration.nix
    ];


  # -- Bootloader --
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = false;
  };

  # Splash screen
  boot = {
    plymouth = {
      enable = true;
      theme = "bgrt"; 
    };

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };


  # -- Kernel & Hardware --
  boot.kernelPackages = pkgs.linuxPackages_latest;


  # -- Networking & Time --
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  
  time.timeZone = "Asia/Jerusalem";
  
  i18n.defaultLocale = "en_IL.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IL.UTF-8";
    LC_IDENTIFICATION = "en_IL.UTF-8";
    LC_MEASUREMENT = "en_IL.UTF-8";
    LC_MANETARY = "en_IL.UTF-8";
    LC_NAME = "en_IL.UTF-8";
    LC_NUMERIC = "en_IL.UTF-8";
    LC_PAPER = "en_IL.UTF-8";
    LC_TELEPHONE = "en_IL.UTF-8";
    LC_TIME = "en_IL.UTF-8";
  };


  # --- Nvidia Driver (v580) ---
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Recommended for Steam/Wine
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;

    open = false; 

    nvidiaSettings = false;
    
    # Force the 580 series driver
    package = config.boot.kernelPackages.nvidiaPackages.production; 
  };

  # CUDA Support
  nixpkgs.config.cudaSupport = true;
  nixpkgs.config.allowUnfree = true;


  # -- Audio --
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };


  # -- Display Manager & DE --
  services.xserver.enable = true;

  # KDE Plasma 6 (Wayland)
  services.displayManager.ly = {
    enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  # Kmscon
  services.kmscon = {
    enable = true;
    hwRender = true;
    fonts = [
      { name = "JetBrainsMono Nerd Font"; package = pkgs.nerd-fonts.jetbrains-mono; }
    ];
    extraConfig = ''
      font-size=14
    '';
  };


  # -- Users --
  users.users.root = {
    shell = pkgs.fish;
    password = "56787";
  };

  users.users.luigofull = {
    isNormalUser = true;
    description = "luigoFull";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "audio" ];
    shell = pkgs.fish;
    password = "56787";
  };


  # -- Programs & Environment --
  programs.fish.enable = true;
  
  # Docker
  virtualisation.docker.enable = true;

  # Packages
  environment.systemPackages = with pkgs; [
    vim
    tmux
    git
    unzip
    p7zip
    htop
    neofetch
    pulsemixer
    docker-compose
    
    zulu21
    zulu25

    firefox
  ];


  # -- Flakes Settings --
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  system.stateVersion = "25.11";
}