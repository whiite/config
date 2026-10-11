# config

Stores configuration files I share across machines.

I only keep track of configs within `~/.config` and use `stow` to link the
contents of this repo into the right place

[Mirrored on GitHub at `whiite/config`](https://github.com/whiite/config) from
[GitLab at `monokuro/config`](https://gitlab.com/monokuro/config)

## Setup

### NixOS VM

The NixOS VM (declared within `nixos/`) sets up this repo automatically on first
boot and stows it into `~/.config`. `/etc/nixos` is symlinked to
`~/src/config/nixos`, so a bare `nixos-rebuild switch` works. See
[`nixos/README.md`](nixos/README.md).

### Manual

The easiest way is [`just`](https://github.com/casey/just), which wraps the
[`stow`](https://www.gnu.org/software/stow/) command:

```bash
# Restow this repo into ~/.config (works from any directory)
just stow
```

`just unstow` removes every symlink it manages (e.g. when decommissioning a
machine). The same `justfile` works on macOS and NixOS; on macOS install the
prerequisites with `brew install stow just`.

Without `just`, run stow directly from the root of this repo:

```bash
# Ensure ~/.config exists if not already
mkdir ~/.config

stow -vR --target $HOME/.config .
```

Unsure why but on MacOS the lazygit config may be needed in a different
directory

```bash
cp lazygit/config.yaml ~/Library/Application\ Support/lazygit/config.yml
```

Configs for lazygit, neovim and kitty are setup to use nerd font icons which can
be installed

Homebrew install

```bash
brew install --cask font-symbols-only-nerd-font
```

### Ansible (WIP)

_Still figuring out this approach - do not use_

Ensure `ansible` is installed

```bash
ansible-playbook setup.yaml
```
