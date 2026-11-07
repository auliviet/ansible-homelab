# MANUAL STEPS

Things that can't be automated by Ansible, or that must happen before it can run.
Follow them in order on a fresh install.

## Mac (control node)

- [ ] Install Homebrew: see https://brew.sh
- [ ] Install Ansible and ansible-lint:
  ```bash
  brew install ansible ansible-lint
  ```
- [ ] Create an SSH key, if there isn't one (store the passphrase in the password manager):
  ```bash
  ssh-keygen -t ed25519 -C "olivier@mac"
  ```
- [ ] Create `~/.ssh/config` with one `Host` entry per machine (see README).
- [ ] Clone this repo and install collections:
  ```bash
  ansible-galaxy collection install -r requirements.yml
  ```
- [ ] Copy the Ansible vault password (from the Passwords app) into the login keychain so `vault-pass.sh` can read it:
  ```bash
  security add-generic-password -a "$USER" -s ansible-vault  -w
  ```
  Test: `ansible-vault view inventory/group_vars/all/vault.yml` opens without asking for password.

## Debian servers (first boot)

Note: Ansible needs _some_ user it can log in as with a SSH key. After the first run, the `common` role creates a user, as defined in `group_vars/all`.

- [ ] Set up SSH key when provisioning the server (either via Raspberry Pi imager or VPS admin portal).
- [ ] On Raspberry Pi, set a username matching the username defined in `group_vars/all`.
- [ ] If a default `debian` user is used when creating the server (e.g. VPS), the first run needs to connect as this default user:

  ```bash
  ansible-playbook playbooks/servers.yml --limit $HOSTNAME -u debian
  ```

  - Before applying `hardening` role, open an SSH connection with the provided user.
  - Test the new username defined in `group_vars/all` can be used to connect via ssh: `ssh $USERNAME@$HOSTNAME` and `sudo whoami`

## Secrets to keep in the password manager

- SSH key passphrase
- Ansible vault password (copy also in the MacOS login keychain)
- Server sudo password (plain copy and hash are also saved in the vault)
