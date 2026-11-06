# MANUAL STEPS

Things that can't be automated by Ansible, or that must happen before it can run.
Follow them in order on a fresh install.

## Mac (control node)

- [ ] Install Homebrew: see https://brew.sh
- [ ] Install Ansible and ansible-lint:
      `bash
  brew install ansible ansible-lint
  `
- [ ] Create an SSH key, if there isn't one (store the passphrase in the password manager):
      `bash
  ssh-keygen -t ed25519 -C "olivier@mac"
  `
- [ ] Create `~/.ssh/config` with one `Host` entry per machine (see README).
- [ ] Clone this repo and install collections:
      `bash
  ansible-galaxy collection install -r requirements.yml
  `

## Debian servers (first boot)

- Set up SSH key when provisioning the server (either via Raspberry Pi imager or VPS admin portal).

## Secrets to keep in the password manager

- SSH key passphrase
