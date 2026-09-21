{
  description = "NixOS VM configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    ...
  }: let
    username = "liam";
    system = "aarch64-linux";
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        # Include the results of the hardware scan.
        ./hardware-configuration.nix

        (
          {
            lib,
            pkgs,
            ...
          }: let
            # Pull unstable packages in from the locked flake input rather than
            # fetching a tarball at evaluation time.
            unstable = import nixpkgs-unstable {
              inherit system;
              config = pkgs.config;
            };
          in {
            nix.settings = {
              # Allows for cross compilation of nix flakes
              trusted-users = [username];
              experimental-features = ["nix-command" "flakes"];
            };
            # Workarounds for aarch64 qemu-user-static build failures:
            # https://github.com/NixOS/nixpkgs/issues/392673
            nixpkgs.overlays = [
              (final: previous:
                lib.optionalAttrs previous.stdenv.hostPlatform.isStatic {
                  nettle = previous.nettle.overrideAttrs {
                    CCPIC = "-fPIC";
                  };
                  # https://github.com/NixOS/nixpkgs/issues/366902
                  qemu-user = previous.qemu-user.overrideAttrs (old: {
                    configureFlags = old.configureFlags ++ ["--disable-pie"];
                  });
                })
            ];

            # Bootloader.
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;

            # Use latest kernel.
            boot.kernelPackages = pkgs.linuxPackages_latest;

            # Cross compilation support
            boot.binfmt.emulatedSystems = ["x86_64-linux"];
            boot.binfmt.preferStaticEmulators = true;

            networking.hostName = "nixos";

            # Configure network proxy if necessary
            # networking.proxy.default = "http://user:password@proxy:port/";
            # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

            # Enable networking
            networking.networkmanager.enable = true;

            # Set your time zone.
            time.timeZone = "Europe/London";

            # Select internationalisation properties.
            i18n.defaultLocale = "en_GB.UTF-8";

            i18n.extraLocaleSettings = {
              LC_ADDRESS = "en_GB.UTF-8";
              LC_IDENTIFICATION = "en_GB.UTF-8";
              LC_MEASUREMENT = "en_GB.UTF-8";
              LC_MONETARY = "en_GB.UTF-8";
              LC_NAME = "en_GB.UTF-8";
              LC_NUMERIC = "en_GB.UTF-8";
              LC_PAPER = "en_GB.UTF-8";
              LC_TELEPHONE = "en_GB.UTF-8";
              LC_TIME = "en_GB.UTF-8";
            };

            # Configure keymap in X11
            services.xserver.xkb = {
              layout = "gb";
              variant = "colemak";
            };

            # Configure console keymap
            console.keyMap = "uk";

            # Don't require password for sudo
            security.sudo.wheelNeedsPassword = false;

            # Define a user account. Don't forget to set a password with ‘passwd’.
            users.users."${username}" = {
              isNormalUser = true;
              description = "Liam";
              extraGroups = ["networkmanager" "wheel" "docker"];
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP0aaD+MZTqOBQo7DrTg1ODCxPrflpdJL9PdoZxKo2CD NixOS VM"
              ];
              packages = with pkgs; [
                eza
                zoxide
                direnv
                go
                silicon
                erdtree
                delta
                gh
                just
                rustup
                docker
                deno
                nodejs
                tmux
                unstable.atuin
                unstable.tree-sitter
                unstable.opencode
                unstable.lazygit
              ];
              shell = pkgs.fish;
            };

            virtualisation.docker.enable = true;

            environment.sessionVariables = {
              XDG_CACHE_HOME = "$HOME/.cache";
              XDG_CONFIG_HOME = "$HOME/.config";
              XDG_DATA_HOME = "$HOME/.local/share";
              XDG_STATE_HOME = "$HOME/.local/state";
              EDITOR = "nvim";
              PATH = ["$HOME/go/bin"];
              ATUIN_CONFIG = "$HOME/.config/atuin/config.toml";
            };

            # List packages installed in system profile. To search, run:
            # $ nix search wget
            environment.systemPackages = with pkgs; [
              unstable.neovim
              unstable.tailscale
              unzip
              gcc
              fish
              curl
              git
              bat
              jq
              ripgrep
              fzf
              clang
              xclip
              harper
              kubectl
            ];

            # Some programs need SUID wrappers, can be configured further or are
            # started in user sessions.
            # programs.mtr.enable = true;
            # programs.gnupg.agent = {
            #   enable = true;
            #   enableSSHSupport = true;
            # };
            programs.fish = {
              enable = true;
              shellInit = ''
                fish_add_path $HOME/go/bin
              '';
              interactiveShellInit = ''
                atuin init fish | source
              '';
            };

            # List services that you want to enable:

            # Enable the OpenSSH daemon.
            services.openssh = {
              enable = true;
              settings = {
                PasswordAuthentication = false;
                KbdInteractiveAuthentication = false;
                PermitRootLogin = "no";
                AllowUsers = [username];
              };
            };

            # Enable support for looking up `.local` hosts replacing avahi
            services.resolved = {
              enable = true;
              settings.Resolve = {
                MulticastDNS = "yes";
                LLMNR = "yes";
              };
            };

            # Open ports in the firewall.
            # networking.firewall.allowedTCPPorts = [ ... ];
            networking.firewall.allowedUDPPorts = [
              5353 # Required for mDNS
            ];
            # Or disable the firewall altogether.
            # networking.firewall.enable = false;

            # Enable tailscale - operator + up --ssh handled declaratively.
            # The auth key is provisioned by OpenTofu at this path.
            services.tailscale = {
              enable = true;
              extraSetFlags = ["--operator=${username}"];
              authKeyFile = "/etc/tailscale-authkey";
              extraUpFlags = ["--ssh"];
            };

            # Clipboard implementation
            services.clipcat.enable = true;

            # Enables clipboard sharing via UTM and Apple backend
            services.spice-vdagentd.enable = true;

            # Create src directory on boot
            systemd.tmpfiles.rules = [
              "d /home/${username}/src 0755 ${username} users -"
            ];

            # Shared directory
            fileSystems."/mnt/shared" = {
              fsType = "virtiofs";
              device = "share";
              options = [
                "nofail"
                "users"
                "exec"
                "x-systemd.automount"
              ];
            };

            # Bind mount nix configuration
            fileSystems."/etc/nixos" = {
              fsType = "none";
              device = "/mnt/shared/config/nixos";
              depends = [
                "/mnt/shared/config/nixos"
              ];
              options = [
                "bind"
              ];
            };

            # .config overlay
            # inits with host .config but isolates changes to the VM
            fileSystems."/home/${username}/.config" = {
              fsType = "overlay";
              device = "overlay";
              depends = [
                "/mnt/shared/config"
              ];
              options = [
                "userxattr"
                "users"
              ];
              overlay = {
                lowerdir = ["/mnt/shared/config"];
                upperdir = "/home/${username}/.config.nixos";
                workdir = "/workdir/dot-config";
              };
            };

            # This value determines the NixOS release from which the default
            # settings for stateful data, like file locations and database versions
            # on your system were taken. It‘s perfectly fine and recommended to leave
            # this value at the release version of the first install of this system.
            # Before changing this value read the documentation for this option
            # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
            system.stateVersion = "25.11"; # Did you read the comment?
          }
        )
      ];
    };
  };
}
