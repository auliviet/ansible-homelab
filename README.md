# HOMELAB

Ansible setup for my personal machines. This repo is the source of truth:
any machine can be wiped and rebuilt from it plus a backup.

## Machines

| Host      | Hardware       | OS     | Purpose                                       |
| --------- | -------------- | ------ | --------------------------------------------- |
| macos     | MacBook M4     | macOS  | Daily machine and Ansible control node        |
| gandi-vps | Remote VPS     | Debian | Public web app                                |
| # pi5     | Raspberry Pi 5 | Debian | NAS, backup target, media server              |
| # pi4     | Raspberry Pi 4 | Debian | Testing, local apps; first target for changes |
| # nuc     | Intel NUC      | Debian | Heavier local apps (not in use yet)           |

## How it works

- Playbooks run from the Mac over SSH (push model, no agents).
- Host names come from `~/.ssh/config` on the Mac.
- Variables live only in `inventory/`. Roles have no defaults.
- Secrets are kept in ansible-vault.

## Layout

```
ansible.cfg            # Ansible settings (inventory path, output format, vault password script)
vault-pass.sh          # Prints ansible-vault passwrod from MacOS keychain
requirements.yml       # Ansible collections this repo needs
inventory/
  hosts.yml            # Machines and groups
  group_vars/
    all/vars.yml       # Variables for every machine
    all/vault.yml      # Encrypted secrets (password hash, sudo password)
    servers.yml        # Variables for Debian servers
    public_servers.yml # Overrides for public servers
plabyooks/
  servers.yml          # Configure Debian servers
roles/
  common/              # Base steps for Debian (user, SSH, timezone, default packages)
  hardening/           # Security settings
MANUAL-STEPS.md        # Steps that can't be automated
```

## Getting started

First follow `MANUAL-STEPS.md`.
Run every command from the repo root, so Ansible picks up `ansible.cfg`.

```bash
# Install Ansible requirements. Required once, and after editing requirements.yml
ansible-galaxy collection install -r requirements.yml

# Show groups and hosts
ansible-inventory --graph

# Check Ansible can reach every host
ansible all -m ansible.builtin.ping

# First run on a new VPS with debian provided user
# (Hardening blocks subsequent access from provided users after first run)
ansible-playbook playbooks/servers.yml --limit $HOSTNAME --u debian

# Configure one server: dry run first, then apply
ansible-playbook playbooks/servers.yml --limit $HOSTNAME --chek --diff
ansible-playbook playbooks/servers.yml --limit $HOSTNAME
```

## Common commands

```bash
# View or edit ansible-vault secrets
ansible-vault view inventory/group_vars/all/vault.yml
ansible-vault edit inventory/group_vars/all/vault.yml

# Check the code
ansible-lint playbook/servers.yml
```

No `-J` or `-K` needed. Vault password comes from the keychain (`vault-pass.sh`)
and sudo password is stored in the vault.

## Rules

- Dry run first: `--check --diff`.
- Run twice. The second run should report `changed=0`
- Pin versions; update them through Git.
- Tag known-good states: `git tag YYYY-MM-stable`.
