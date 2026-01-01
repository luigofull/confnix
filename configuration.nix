{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # --- Bootloader (GRUB) ---
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = false;
  };

  # --- Kernel & Hardware ---
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --- Networking & Time ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Jerusalem";
  
  # locale
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Nvidia Driver (v580) ---
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Recommended for Steam/Wine
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;

    open = true; 

    nvidiaSettings = true;
    
    # Force the 570 series driver
    package = config.boot.kernelPackages.nvidiaPackages.production; 
  };

  # CUDA Support
  nixpkgs.config.cudaSupport = true;
  nixpkgs.config.allowUnfree = true;

  # --- Audio ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # --- Display Manager & DE ---
  
  # 1) Kmscon
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

  # 2) Ly Display Manager
  services.displayManager.ly = {
    enable = true;
  };

  # 3) KDE Plasma 6 (Wayland)
  services.desktopManager.plasma6.enable = true;
  
  services.displayManager.autoLogin.enable = false; 

  # --- Users ---
  users.users.root = {
    password = "56787";
  };

  users.users.luigofull = {
    isNormalUser = true;
    description = "luigoFull";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "audio" ];
    shell = pkgs.fish;
    password = "56787";
  };

  # --- Programs & Environment ---
  programs.fish.enable = true;
  
  # Docker
  virtualisation.docker.enable = true;

  # Packages
  environment.systemPackages = with pkgs; [
    vim
    tmux
    git
    htop
    neofetch
    pulsemixer
    docker-compose
    
    zulu21
    zulu25
  ];

  # --- Flakes Settings ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  system.stateVersion = "25.11";
}