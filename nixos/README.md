# NixOS dev VM

Declaratively managed NixOS VM, provisioned from this flake and (for
cloud/tailnet resources) the OpenTofu config in this directory.

## Dotfiles

User configuration lives in the shared dotfiles git repo (the same one the host
Mac uses). The VM clones it into `~/src/config` and links it into `~/.config`
with [GNU Stow]. The flake wires this up declaratively:

- `systemd.tmpfiles.rules` ensures `~/.config` exists and symlinks
  `/etc/nixos -> ~/src/config/nixos`, so a bare `nixos-rebuild switch` finds the
  flake.
- `systemd.services.dotfiles-stow` clones
  `git@gitlab.com:monokuro/config.git` to `~/src/config` on first boot if it is
  missing, then runs `stow --restow --target ~/.config .` to create the
  symlinks. It does **not** auto-pull — run `git -C ~/src/config pull` when you
  want updates, then re-stow with `just stow` (or restart the service / reboot).
- Machine-specific git settings (identity, SSH commit signing, credential
  helpers) are declared via `programs.git` rather than committed to the shared
  repo, which keeps the repo portable across machines.

To change configuration by hand, edit files under `~/src/config` and commit;
`just stow` applies any resulting symlink changes (see the root README).

[GNU Stow]: https://www.gnu.org/software/stow/

## Disk layout

The boot disk is described declaratively in `disko.nix`. The partition labels
are pinned to `EFI` and `root`, so the generated `fileSystems` entries use
`/dev/disk/by-partlabel/EFI` and `/dev/disk/by-partlabel/root` instead of
filesystem UUIDs. This makes the configuration host-independent and stable
across re-installs.

`hardware.nix` holds the remaining non-disk hardware bits (initrd kernel
modules and `hostPlatform`). The old `hardware-configuration.nix` has been
removed; disko now generates the filesystem/swap configuration.

> Note: `disko.nix` only *generates configuration* when the flake is evaluated.
> It never touches a disk unless the disko CLI is run with a destructive mode
> (`destroy`, `format`). That is only done when provisioning a fresh machine.

## Provisioning a fresh VM

1. On the host, create a new VM with a blank disk (e.g. UTM/QEMU, ARM64,
   EFI firmware).
2. Boot a NixOS installer ISO in the VM.
3. Make this flake available in the installer by cloning the dotfiles repo.
4. Partition, format and mount the disk using the same config used by the
   running system:

   ```console
   sudo nix run github:nix-community/disko -- \
     --mode destroy,format,mount /path/to/nixos/disko.nix
   ```

   To target a disk other than `/dev/vda`, override it with `--arg`/`--disk`
   as appropriate for the machine.

5. Install NixOS from the flake:

   ```console
   sudo nixos-install --flake /path/to/nixos#nixos
   ```

6. Reboot into the installed system.

Remaining host-side steps that are not managed by NixOS: providing the
Tailscale auth key (provisioned by OpenTofu at `/etc/tailscale-authkey`). On
first boot the VM clones the dotfiles repo into `~/src/config` and stows it into
`~/.config` (see [Dotfiles](#dotfiles)).

## Migrating an existing VM (no disk change)

The current VM's disk already matches the declared layout, so the migration is
config-only:

1. Add `disko.nix`, `hardware.nix`, and the flake changes.
2. Verify the generated mounts resolve to the existing partitions:

   ```console
   ls -l /dev/disk/by-partlabel/
   nix eval '/path/to/nixos#nixosConfigurations.nixos.config.fileSystems' --json
   ```

3. Build, switch, and reboot:

   ```console
   sudo nixos-rebuild switch --flake /path/to/nixos
   sudo reboot
   ```

Rollback is available via the previous generation in the systemd-boot menu;
the disk itself is never modified by this process.
