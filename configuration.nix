# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{emacs-overlay, ...}:
{ config, pkgs, unstable, ... }:

{
  # AMD EPYC 4564P ?

  # nixpkgs.hostPlatform = {
  #   gcc.arch = "skylake";
  #   gcc.tune = "skylake";
  #   system = "x86_64-linux";
  # };

  nix = {
    # https://github.com/NixOS/nix/issues/11728#issuecomment-2613076734 for download-buffer-size
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
      download-buffer-size = 500000000
    '';
    nrBuildUsers = 64;
    settings = {
      system-features = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
        "gccarch-alderlake"
        "gccarch-skylake"
        "gccarch-znver4"
        "gccarch-x86-64-v3"
      ];
      # auto-optimise-store = true;
      max-jobs = "auto";
      cores = 0; # how many should I allow?
      min-free = 10 * 1024 * 1024;
      max-free = 200 * 1024 * 1024;

      trusted-users = [ "root" "shae" "remotebuild" ];
      substituters = [
        "http://nix-community.cachix.org"
        "https://cache.iog.io"
        "https://cache.nixos.org"
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };
  };
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  powerManagement.cpuFreqGovernor = "performance";

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportRoot = false;
      extraPools = [ "droplet" ];
      devNodes = "/dev/disk/by-id";
    };
    loader = {
      # Bootloader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # latest kernel that supports ZFS? linuxPackages_6_17 builds!
    kernelPackages = pkgs.linuxPackages_6_17;
    initrd = {
      network.ssh = {
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYlatXccSMal4uwSogKUEfJgrJ3YsH2uSbLFfgz6Vam" ];
        enable = true;
      };
    };
  };

  networking = {

    hostName = "guanbacex"; # Define your hostname.
    hostId = "1a27d3b4";
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager.enable = true;

    # Open ports in the firewall.
    firewall.allowedTCPPorts = [
      22 # ssh
      873 # rsyncd
    ];
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services = {

    tailscale = {
      enable = true;
    };

    rsyncd = {
      enable = true;
    };

    smartd = {
      enable = true;
      devices = [ {device = "/dev/sda";} {device = "/dev/sdb";} {device = "/dev/sdc";} {device = "/dev/sdd";}];
      defaults.monitored = "-a -o on -s (S/../.././02|L/../../7/04)";
    };

    avahi = {
      enable = true;
      publish.enable = true;
      publish.userServices = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    fwupd.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
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

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    openssh.enable = true;
  };

  security.rtkit.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.shae = {
    isNormalUser = true;
    description = "Shae Erisson";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYlatXccSMal4uwSogKUEfJgrJ3YsH2uSbLFfgz6Vam" ];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };
  users.users.remotebuild = {
    isSystemUser = true;
    group = "remotebuild";
    useDefaultShell = true;
    openssh.authorizedKeys.keyFiles = [ ./remotebuild.pub ];
  };
  users.groups.remotebuild = {};


  # Install firefox.
  # programs.firefox.enable = true;
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    acpi
    btop
    direnv
    fzf
    git
    htop
    screen
    starship
    vim
    wget
    zoxide
    smartmontools
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
