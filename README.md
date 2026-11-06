# HOMELAB

Ansible setup for my personal machines. This repo is the source of truth:
any machine can be wiped and rebuilt from it plus a backup.

## Machines

| Host      | Hardware       | OS     | Purpose                                       |
| --------- | -------------- | ------ | --------------------------------------------- |
| mac       | MacBook M4     | macOS  | Daily machine and Ansible control node        |
| gandi-vps | Remote VPS     | Debian | Public web app                                |
| # pi5     | Raspberry Pi 5 | Debian | NAS, backup target, media server              |
| # pi4     | Raspberry Pi 4 | Debian | Testing, local apps; first target for changes |
| # nuc     | Intel NUC      | Debian | Heavier local apps (not in use yet)           |

## How it works

- Playbooks run from the Mac over SSH (push model, no agents).
- Host names come from `~/.ssh/config` on the Mac.
- Variables live only in `inventory/`. Roles have no defaults.

## Layout

```
ansible.cfg          # Ansible settings (inventory path, output format)
requirements.yml     # Ansible collections this repo needs
inventory/
  hosts.yml          # machines and groups
  group_vars/all/    # variables for every machine
MANUAL-STEPS.md      # steps that can't be automated
```

## Getting started

Run every command from the repo root, so Ansible picks up `ansible.cfg`.

```bash
ansible-galaxy collection install -r requirements.yml   # once, and after editing requirements.yml
ansible-inventory --graph                               # show groups and hosts
ansible all -m ansible.builtin.ping                     # check Ansible can reach every host
```

## Rules

- Dry run first: `--check --diff`.
- Test every change on `pi4` first: `--limit pi4`.
- Pin versions (collections, Docker images); update them through Git.
- Tag known-good states: `git tag YYYY-MM-stable`.
