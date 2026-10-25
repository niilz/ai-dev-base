#!/usr/bin/env bash
set -euo pipefail

# Set fish as the default login shell before revoking sudo access,
# as chsh requires elevated privileges to modify /etc/passwd without a password prompt.
sudo chsh -s /usr/bin/fish vscode

# Permanently revoke sudo privileges so the runtime environment and AI agents
# cannot alter system-level packages or firewall rules after initialization.
sudo rm -f /etc/sudoers.d/vscode

# Symlink dotfiles from the image-baked /opt/dev-configs repository into $HOME.
dotbot -c /opt/dotbot.yaml -d /opt/dev-configs

# Install pi-coding-agent into user-scoped PNPM_HOME (/home/vscode/.local/share/pnpm).
# --ignore-scripts prevents arbitrary postinstall script execution.
pnpm add -g --ignore-scripts @earendil-works/pi-coding-agent rea-agents
pi install npm:pi-antigravity
pi install npm:@earendil-works/pi-voice

# Install shared agent skills globally into ~/.agents/skills (and symlinked into ~/.claude/skills).
# dotbot links ~/.gemini/config/skills and ~/.config/opencode/skills to ~/.agents/skills so all agents share them.
npx --yes skills add herdrdev/herdr --skill herdr -g -a opencode -a pi -a claude-code -y
