# config

Stores configuration files I share across machines.

I only keep track of configs within `~/.config` and use `stow` to link
the contents of this repo into the right place

## Setup

### Manual

Will need to install `stow` then:

```bash
# Ensure ~/.config exists if not already
mkdir ~/.config

# Within the root of this repo run:
stow -vR --target $HOME/.config .
```

Unsure why but on MacOS the lazygit config may be needed in a different directory

```bash
cp lazygit/config.yaml ~/Library/Application\ Support/lazygit/config.yml
```

Configs for lazygit, neovim and kitty depend are setup to use nerd font icons.

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
