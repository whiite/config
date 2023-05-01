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

# Within the route of this repo run:
stow -vR --target $HOME/.config .
```

### Ansible (WIP)

_Still figuring out this approach - do not use_

Ensure `ansible` is installed

```bash
ansible-playbook setup.yaml
```
