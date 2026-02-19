(playbook "debops/ansible/roles/nixos/defaults/main.yml"
  (nixos__config_dir "/etc/nixos")
  (nixos__src (jinja "{{ inventory_dir | realpath + \"/../nixos/\" }}"))
  (nixos__rebuild "True")
  (nixos__rebuild_command "nixos-rebuild switch")
  (nixos__distribution_string "NixOS")
  (nixos__git_resync "False")
  (nixos__git_resync_options (list
      "--ignore-existing"))
  (nixos__git_backup_dir (jinja "{{ nixos__config_dir + \".ansible-backup\" }}"))
  (nixos__repositories (list))
  (nixos__group_repositories (list))
  (nixos__host_repositories (list))
  (nixos__default_configuration (list
      
      (name "configuration.nix")
      (comment "Edit this configuration file to define what should be installed on
your system. Help is available in the configuration.nix(5) man page, on
https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
")
      (raw "{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Enable support for Nix Flakes
  # nix.settings.experimental-features = [ \"nix-command\" \"flakes\" ];

  # Allow non-free packages
  # nixpkgs.config.allowUnfree = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = \"/boot/efi\";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = \"/dev/vda\"; # or \"nodev\" for efi only

  # networking.hostName = \"nixos\"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = \"Etc/UTC\";

  # Configure network proxy if necessary
  # networking.proxy.default = \"http://user:password@proxy:port/\";
  # networking.proxy.noProxy = \"127.0.0.1,localhost,internal.domain\";

  # Select internationalisation properties.
  # i18n.defaultLocale = \"en_US.UTF-8\";
  # console = {
  #   font = \"Lat2-Terminus16\";
  #   keyMap = \"us\";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = \"us\";
  # services.xserver.xkb.options = \"eurosign:e,caps:escape\";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ansible = {
    isNormalUser = true;
    extraGroups = [ \"wheel\" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      htop
      tree
    ];

    # Add SSH agent public keys to user's ~/.ssh/authorized_keys
    openssh.authorizedKeys.keys = [
      \"" (jinja "{{ lookup('pipe', 'ssh-add -L | grep ^\\\\\\(sk-\\\\\\)\\\\\\?ssh || cat ~/.ssh/*.pub || cat ~/.ssh/authorized_keys || true') }}") "\"
    ];
  };

  # Allow the \"ansible\" user to elevate privileges without specifying a password
  security.sudo.extraRules= [
    { users = [ \"ansible\" ];
      commands = [
         { command = \"ALL\" ;
           options= [ \"NOPASSWD\" \"SETENV\" ];
        }
      ];
    }
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    pkgs.pipx
    python3
    tmux
    tree
    vim
    wget
  ];

  # Include ~/.local/bin in user's $PATH by default
  environment.localBinInPath = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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
  system.stateVersion = \"24.05\"; # Did you read the comment?

}
")
      (state "ignore")))
  (nixos__configuration (list))
  (nixos__group_configuration (list))
  (nixos__host_configuration (list))
  (nixos__combined_configuration (jinja "{{ nixos__default_configuration
                                   + nixos__configuration
                                   + nixos__group_configuration
                                   + nixos__host_configuration }}"))
  (nixos__templates (list
      (jinja "{{ nixos__src + \"templates/by-group/all\" }}")))
  (nixos__group_templates (jinja "{{ group_names | map(\"regex_replace\", \"^(.*)$\", nixos__src + \"templates/by-group/\\1\") | list }}"))
  (nixos__host_templates (list
      (jinja "{{ nixos__src + \"templates/by-host/\" + inventory_hostname }}"))))
