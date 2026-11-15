# MANUAL STEPS

Things that can't be automated by Ansible, or that must happen before it can run.
Follow them in order on a fresh install.

## Mac (control node)

On a fresh MacOS install, follow this order.

### Before running Ansible

- [ ] Sign in to iCloud. Passwords app holds the Ansible vault password.
- [ ] Sign in to Apple Store. `mas` cannot sign in and can only install apps already purchased.
- [ ] Install Homebrew:
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```
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
  ansible-galaxy collection install -r requirements.yml --upgrade
  ```

  Run every Ansible command from the repo root, so Ansible picks up `ansible.cfg`.

- [ ] Copy the Ansible vault password (from the Passwords app) into the login keychain so `vault-pass.sh` can read it:
  ```bash
  security add-generic-password -a "$USER" -s ansible-vault  -w
  ```
  Test: `ansible-vault view inventory/group_vars/all/vault.yml` opens without asking for password.

### Vault variables

Two secrets are encrypted in ansible-vault (`inventory/groupvars/all/vault.yml`). Both must exist before `configure-servers.yml` can run.

| Variable                   | Content                  | Used by                                           |
| -------------------------- | ------------------------ | ------------------------------------------------- |
| `vault-user-password`      | Plain text password      | `ansible_become_password` so Ansible can use sudo |
| `vault-user-password-hash` | SHA-512 hash of password | `use_password_hash` to create a new user          |

**On a fresh Mac, these should already exist.**
`vault.yml` is tracked in the repo and encrypted. Once the vault password is in the keychain, both variables are accessible with:

```bash
ansible-vault view inventory/group_vars/all/vault.yml
```

To create them from scratch (new vault or new server password):

- [ ] Generate the hash:
  ```bash
  $(brew --prefix openssl@3)/bin/openssl passwd -6
  ```
- [ ] Add both variables to the vault.
- [ ] Save the plain password in a password manager.

### Run the playbook

- [ ] Dry run, then apply:
  ```bash
  ansible-playbook playbooks/configure-mac.yml --check --diff
  ansible-playbook playbooks/configure-mac.yml
  ```
  On a fresh install, the dry run may fail due to some required apps missing.
- [ ] Run it a second time. It should report `changed=0`.

### After the first run

- [ ] Open a new terminal window so the dotfiles take effect.
- [ ] After the first run of `configure-mac.yml`, open iTerm > Settings > Profiles. Select the `Dotfiles` profile and set as default.

### Patching

Run `patch-mac.yml` roughly once a month. It upgrades Homebrew formulae and App Store apps.

- [ ] Ensure you are signed in to App Store.
- [ ] Quit all applications. Upgraded apps need to be restarted.
- [ ] Upgrade casks in a terminal, as it requires sudo password:
  ```bash
  brew upgrade --cask
  ```

## Debian servers

### First boot

Note: Ansible needs _some_ user it can log in as with a SSH key. After the first run, the `common` role creates a user, as defined in `group_vars/all`.

- [ ] Set up SSH key when provisioning the server (either via Raspberry Pi imager or VPS admin portal).
- [ ] On Raspberry Pi, set a username matching the username defined in `group_vars/all`.
- [ ] If a default `debian` user is used when creating the server (e.g. VPS), the first run needs to connect as this default user:

  ```bash
  ansible-playbook playbooks/configure-servers.yml --limit $HOSTNAME -u debian
  ```

- [ ] Before applying `hardening` role, open an SSH connection with the provided user.
- [ ] Test the new username defined in `group_vars/all` can be used to connect via ssh: `ssh $USERNAME@$HOSTNAME` and `sudo whoami`

### Patching

Run `patch-servers.yml` roughly once a month. It install lastest packages and reboot the servers.
After each upgrade:

- [ ] Check that SSH is working
- [ ] Check that the app installed are accessible

## Secrets to keep in the password manager

- SSH key passphrase
- Ansible vault password (copy also in the MacOS login keychain)
- Server sudo password (plain copy and hash are also saved in the vault)
