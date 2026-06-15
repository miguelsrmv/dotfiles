#!/usr/bin/env bash
#
# fedora-postinstall.sh (v2)
# Fedora Workstation 44 setup — ThinkPad X1 Carbon Gen 14
#
# Run as your normal user (it calls sudo where needed):
#   bash fedora-postinstall.sh
#
# Safe to re-run: steps are guarded where they aren't naturally idempotent.
# Prerequisite done in the installer: "Encrypt my data" (LUKS) was ticked.

set -euo pipefail

# Under strict mode a failing command aborts the script; this trap makes it say
# WHERE and WHY before exiting, instead of dying silently. (Commands allowed to
# fail are guarded with '|| true' individually.)
trap 'echo "✗ FAILED at line ${LINENO}: ${BASH_COMMAND} (exit $?)" >&2' ERR

if [[ $EUID -eq 0 ]]; then
  echo "Run this as your regular user, not root (sudo is used where needed)." >&2
  exit 1
fi

FEDORA_VER="$(rpm -E %fedora)"
step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# $USER isn't guaranteed to be set (some sudo/su/cron contexts clear it), and
# under 'set -u' an empty $USER would abort the script. Pin it once via id -un
# so every "$USER" below is safe.
USER="${USER:-$(id -un)}"

# ------------------------------------------------- interactive bits, up front
# Pre-set these (e.g. GIT_NAME="x" GIT_EMAIL="y" bash fedora-postinstall.sh)
# to run non-interactively.
GIT_NAME="${GIT_NAME:-}"
GIT_EMAIL="${GIT_EMAIL:-}"
[[ -n "$GIT_NAME"  ]] || read -rp "Git user.name : " GIT_NAME
[[ -n "$GIT_EMAIL" ]] || read -rp "Git user.email: " GIT_EMAIL

# Hostname for this machine (shows up in Tailscale, ssh, your prompt).
NEW_HOSTNAME="${NEW_HOSTNAME:-x1carbon}"

# ------------------------------------------------------------------ hostname
step "Hostname -> ${NEW_HOSTNAME}"
if [[ "$(hostnamectl --static)" != "${NEW_HOSTNAME}" ]]; then
  sudo hostnamectl set-hostname "${NEW_HOSTNAME}"
  sudo hostnamectl set-hostname --pretty "ThinkPad X1 Carbon Gen 14"
fi

# ---------------------------------------------------------------- base system
step "Base system update"
sudo dnf -y upgrade --refresh
sudo dnf -y install dnf5-plugins   # provides 'dnf copr' and 'dnf config-manager'

step "Firmware updates (Lenovo ships X1 Carbon firmware via LVFS)"
fwupdmgr refresh --force || true
fwupdmgr update || true            # may stage a reboot; failures here are non-fatal

# ----------------------------------------------------------------- rpm fusion
step "RPM Fusion (free + nonfree)"
rpm -q rpmfusion-free-release >/dev/null 2>&1 || sudo dnf -y install \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm"
rpm -q rpmfusion-nonfree-release >/dev/null 2>&1 || sudo dnf -y install \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"

step "Full multimedia stack (codecs + Intel hardware decode)"
# Fedora's ffmpeg-free is patent-stripped; swap in RPM Fusion's full build.
if rpm -q ffmpeg-free >/dev/null 2>&1; then
  sudo dnf -y swap ffmpeg-free ffmpeg --allowerasing
fi
# GStreamer plugins for GNOME apps, thumbnails, etc.
sudo dnf -y update @multimedia \
  --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
# VA-API driver for the Panther Lake iGPU (kept out of Fedora for patent reasons)
sudo dnf -y install intel-media-driver libva-utils
sudo dnf -y install akmod-v4l2loopback # For obs virtual-cam

# --------------------------------------------------------------------- coprs
step "COPRs"
sudo dnf -y copr enable atim/starship
sudo dnf -y copr enable scottames/ghostty
sudo dnf -y copr enable dejan/lazygit
sudo dnf -y copr enable lihaohong/yazi

# -------------------------------------------------------------- vendor repos
step "Vendor repos (Tailscale, 1Password)"
[[ -f /etc/yum.repos.d/tailscale.repo ]] || sudo dnf config-manager addrepo \
  --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
if [[ ! -f /etc/yum.repos.d/1password.repo ]]; then
  sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
  sudo tee /etc/yum.repos.d/1password.repo >/dev/null <<'EOF'
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF
fi

# ------------------------------------------------------------------ packages
step "Packages (dnf)"
sudo dnf -y install \
  zsh stow git vim neovim tmux btop \
  starship ghostty lazygit yazi nautilus-python \
  python3 python3-pip nodejs npm gcc gcc-c++ make \
  thunderbird gimp steam \
  podman podman-compose freerdp \
  tailscale 1password \
  openssh-server \
  distrobox igt-gpu-tools \
  qbittorrent lm_sensors
# nautilus-python: lets Ghostty's bundled "Open in Ghostty" Files entry load.
# qbittorrent: de facto torrent client (transmission-gtk is the GNOME-native swap).
# lm_sensors: 'sensors' for temps; run 'sudo sensors-detect' once if temps don't show.
# LibreOffice as an RPM (not Flatpak) so the Zotero plugin integrates painlessly:
sudo dnf -y install libreoffice
sudo dnf -y install ripgrep fd-find   # common Neovim/Telescope helpers

step "tree-sitter CLI (via npm; gcc/make above let nvim-treesitter build parsers)"
sudo npm install -g tree-sitter-cli

sudo systemctl enable --now tailscaled

# ------------------------------------------------------------------------ uv
step "uv (Python package/venv manager — Astral standalone installer)"
# Your dotfiles assume uv: the ~/.local/bin/env line in .zshrc, project .envrc
# files, and venv 'activate' all depend on it. The STANDALONE installer (not
# dnf/pip) is what creates ~/.local/bin/env, so we use it deliberately.
if ! command -v uv >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/uv" ]]; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
# (uv lands in ~/.local/bin; a new shell or 'hash -r' picks it up. If a dnf/pip
#  'uv' ever shadows it, remove that one — the standalone install is canonical.)

# ------------------------------------------------------ winapps prerequisites
step "WinApps prerequisites (rootless Podman Windows VM)"
# Lets the dockur/WinApps Windows VM start and share folders. WinApps setup
# itself (git clone + bash setup.sh) stays manual — see follow-ups.
sudo usermod -aG kvm "$USER"      # /dev/kvm for rootless podman (needs a relog)
sudo dnf -y install crun          # crun (NOT runc) required for keep-groups
# iptables modules for WinApps folder sharing (empty 'lsmod | grep' = needed):
echo -e "ip_tables\niptable_nat" | sudo tee /etc/modules-load.d/iptables.conf >/dev/null
sudo modprobe ip_tables iptable_nat 2>/dev/null || true
# In compose.yaml use  ${HOME}/winapps-shared:/shared:Z  (a SUBFOLDER) — NEVER
# ${HOME}:/shared:Z, which SELinux refuses (can't relabel all of $HOME).

# ------------------------------------------------------- cloud sync (Insync)
step "Cloud sync — Insync (Google Drive) is the primary tool"
# Insync (proprietary GUI client for Google Drive). This is the main sync tool.
if [[ ! -f /etc/yum.repos.d/insync.repo ]]; then
  sudo tee /etc/yum.repos.d/insync.repo >/dev/null <<'EOF'
[insync]
name=insync repo
baseurl=http://yum.insync.io/fedora/$releasever/
gpgcheck=1
gpgkey=https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key
enabled=1
EOF
fi
sudo dnf -y install insync
# Getting Insync running (manual — it's a GUI app, needs a browser sign-in):
#   1. Launch 'Insync' from the app grid (or run 'insync start' then 'insync show').
#   2. Sign in with your Google account in the window that opens.
#   3. Pick the local sync folder (you used ~/Insync/<account>/Google Drive) and
#      choose which Drive folders to sync. Selective-sync lives in the GUI.
#   4. Optional: symlink XDG dirs into the synced folder, e.g.
#      ln -sfn "$HOME/Insync/<account>/Google Drive/Documents" "$HOME/Documents"
#   Insync autostarts on login once configured (it adds its own .desktop entry).
#
# Fallback — OneDrive via the abraunegg client (lean, config in ~/.config/onedrive):
# sudo dnf -y install onedrive
# then: onedrive            # authenticate once
#       systemctl --user enable --now onedrive

# ------------------------------------------------------------------ flatpaks
step "Flathub + Flatpak apps (system-wide — sole-user machine, default scope)"
sudo flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y --noninteractive flathub \
  com.discordapp.Discord \
  com.spotify.Client \
  org.zotero.Zotero \
  com.obsproject.Studio \
  com.rtosta.zapzap \
  com.github.tchx84.Flatseal
# ZapZap = unofficial WhatsApp client; swap for a browser PWA if you prefer.
# Flatseal = GUI for Flatpak permissions (e.g. give Zotero extra file access).

# ---------------------------------------------------------------------- fonts
step "Fonts (MS core fonts, JetBrains + FiraCode Nerd Fonts)"

# --- Microsoft core fonts (Arial, Times New Roman, Courier New, Verdana, ...) ---
# Not in Fedora repos (licensing); this installer pulls them from Microsoft's
# own redistribution. NOTE: this set does NOT include Calibri/Cambria (modern
# Office defaults) — see the comment block at the end of this section for those.
sudo dnf -y install curl cabextract xorg-x11-font-utils fontconfig unzip
rpm -q msttcore-fonts-installer >/dev/null 2>&1 || sudo rpm -i \
  https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm || true

# --- Nerd Fonts: JetBrainsMono + FiraCode -------------------------------------
# The *Nerd Font* (glyph-patched) variants — not Fedora's plain jetbrains-mono-fonts.
# Pulled from the ryanoasis/nerd-fonts releases into your user font dir.
mkdir -p "$HOME/.local/share/fonts/nerd-fonts"
for nf in JetBrainsMono FiraCode; do
  if ! fc-list | grep -qi "${nf}.*Nerd"; then
    tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/${nf}.zip" \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${nf}.zip" \
      && unzip -oq "$tmp/${nf}.zip" -d "$HOME/.local/share/fonts/nerd-fonts" \
      && echo "  installed ${nf} Nerd Font" || echo "  WARN: ${nf} Nerd Font download failed"
    rm -rf "$tmp"
  fi
done

fc-cache -f   # rebuild font cache so every app (incl. LibreOffice on restart) sees them

# --- Proxima Nova & Merrant (CANNOT be automated — paid commercial fonts) -----
# Proxima Nova is a paid font (Mark Simonson / sold via Adobe Fonts, Fontspring,
# etc.). Merrant is likewise a paid display typeface (Max Prive, sold via
# MyFonts). Neither has a legal free download (the "free" sites are piracy
# mirrors — avoid them). To use either:
#   - Activate via an Adobe Fonts (Creative Cloud) subscription where available, OR
#   - Buy a desktop license, then drop the .otf/.ttf files into
#     ~/.local/share/fonts/  and run  fc-cache -f.
# (Merrant is a display face for headlines/logos, not a document/text font.)
#
# --- Calibri / Cambria (modern Office defaults — from YOUR Windows licence) ----
# Not in the redistributable MS set above. The clean, licence-legitimate route
# is to copy them out of your WinApps VM (you own that Windows licence):
#   1. In the VM, copy C:\Windows\Fonts\*  ->  \\host.lan\Data  (= ~/winapps-shared)
#   2. cp ~/winapps-shared/winfonts/*.{ttf,ttc,otf} ~/.local/share/fonts/microsoft/
#   3. fc-cache -f   &&   fully restart LibreOffice
#   Calibri/Cambria keep .docx files laying out identically to Office (metrics).

# ----------------------------------------------------------- gnome extensions
step "GNOME extensions (edit this list to taste)"
# dnf-packaged extensions update with the system and survive GNOME upgrades.
GNOME_EXT_PKGS=(
  gnome-tweaks
  gnome-shell-extension-dash-to-dock
  gnome-shell-extension-caffeine
  gnome-shell-extension-blur-my-shell
)
sudo dnf -y install --skip-unavailable "${GNOME_EXT_PKGS[@]}"
# Enable now; they load on your next login. Anything not packaged by Fedora:
# install from extensions.gnome.org in Firefox, or 'pip install --user gnome-extensions-cli'.
if command -v gnome-extensions >/dev/null 2>&1; then
  for uuid in \
    appindicatorsupport@rgcjonas.gmail.com \
    dash-to-dock@micxgx.gmail.com \
    caffeine@patapon.info \
    blur-my-shell@aunetx
  do gnome-extensions enable "$uuid" 2>/dev/null || true; done
fi

# ------------------------------------------------------- desktop appearance
step "Desktop appearance: dark mode + Papirus-Dark icons"
# GNOME dark mode (this is the modern libadwaita-aware switch).
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' || true

# Papirus icon theme (the most popular third-party icon set) -> Papirus-Dark.
sudo dnf -y install --skip-unavailable papirus-icon-theme
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' || true
# Note: gsettings here apply to the user running this script; they take effect
# immediately (or on next login for a few shell elements).

# -------------------------------------------------------- user avatar (face)
step "User avatar for GDM / Settings (AccountsService)"
# GNOME ignores ~/.face now; the avatar lives in AccountsService. Point AVATAR
# at any square PNG/JPG; defaults to ~/.face if present.
AVATAR="${AVATAR:-$HOME/.face}"
if [[ -f "$AVATAR" ]]; then
  sudo cp "$AVATAR" "/var/lib/AccountsService/icons/$USER"
  sudo mkdir -p /var/lib/AccountsService/users
  if ! sudo grep -qs "^Icon=" "/var/lib/AccountsService/users/$USER" 2>/dev/null; then
    printf '[User]\nIcon=/var/lib/AccountsService/icons/%s\n' "$USER" \
      | sudo tee -a "/var/lib/AccountsService/users/$USER" >/dev/null
  fi
  sudo systemctl restart accounts-daemon 2>/dev/null || true
else
  echo "  no avatar image at $AVATAR — skipping (set AVATAR=/path/to/img to use one)."
fi

# ---------------------------------------------------------- firefox extensions
# (Removed: you manage extensions via Firefox Sync, not enterprise policy.
#  Sync restores uBlock, 1Password, Zotero across machines; sign into Sync once.
#  If Sync ever doesn't auto-reinstall an add-on on a fresh profile, open the
#  add-ons list to nudge it. Bonjourr was dropped — it crashed Firefox on boot.)

# ----------------------------------------------------------- git and ssh keys
step "Git config + SSH keys for GitHub and Codeberg"
# Respect a stowed git config: only write if none exists yet.
if [[ ! -f "$HOME/.gitconfig" && ! -f "$HOME/.config/git/config" ]]; then
  git config --global user.name  "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
  git config --global init.defaultBranch main
  git config --global core.editor nvim
else
  echo "  existing git config found — leaving it alone (stow wins)."
fi

mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
for host in github codeberg; do
  key="$HOME/.ssh/id_ed25519_${host}"
  # No passphrase: the disk is LUKS-encrypted. Add one later with: ssh-keygen -p -f <key>
  [[ -f "$key" ]] || ssh-keygen -t ed25519 -f "$key" -N "" -C "${GIT_EMAIL} (${host})"
done

touch "$HOME/.ssh/config" && chmod 600 "$HOME/.ssh/config"
if ! grep -q "^Host github.com" "$HOME/.ssh/config"; then
  cat >>"$HOME/.ssh/config" <<EOF

Host github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github
  IdentitiesOnly yes

Host codeberg.org
  User git
  IdentityFile ~/.ssh/id_ed25519_codeberg
  IdentitiesOnly yes
EOF
fi

# ------------------------------------------------------------ btrfs snapshots
step "Btrfs snapshots (snapper + dnf5 pre/post + Btrfs Assistant GUI)"
sudo dnf -y install snapper libdnf5-plugin-actions btrfs-assistant

[[ -f /etc/snapper/configs/root ]] || sudo snapper -c root create-config /
[[ -f /etc/snapper/configs/home ]] || sudo snapper -c home create-config /home

# Sane retention (defaults keep far too much). Tune freely.
sudo snapper -c root set-config TIMELINE_CREATE=yes \
  TIMELINE_LIMIT_HOURLY=5 TIMELINE_LIMIT_DAILY=7 \
  TIMELINE_LIMIT_WEEKLY=2 TIMELINE_LIMIT_MONTHLY=1 TIMELINE_LIMIT_YEARLY=0
sudo snapper -c home set-config TIMELINE_CREATE=yes \
  TIMELINE_LIMIT_HOURLY=5 TIMELINE_LIMIT_DAILY=7 \
  TIMELINE_LIMIT_WEEKLY=0 TIMELINE_LIMIT_MONTHLY=0 TIMELINE_LIMIT_YEARLY=0

sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer

# dnf5 has no native snapper plugin; this actions file recreates the dnf4
# behavior (pre/post snapshot around every transaction). Source: dnf5 docs
# example, via dustymabe.com's Fedora BTRFS+snapper series.
sudo mkdir -p /etc/dnf/libdnf5-plugins/actions.d
if [[ ! -f /etc/dnf/libdnf5-plugins/actions.d/snapper.actions ]]; then
  sudo tee /etc/dnf/libdnf5-plugins/actions.d/snapper.actions >/dev/null <<'EOF'
# Emulates the DNF4 snapper plugin using the "snapper" command-line program.
# Creates a pre snapshot before the transaction, stores its number, then a
# paired post snapshot afterwards.
pre_transaction::::/usr/bin/sh -c echo\ "tmp.snapper_desc=$(ps\ -o\ command\ --no-headers\ -p\ '${pid}')"
pre_transaction::::/usr/bin/sh -c echo\ "tmp.snapper_pre_number=$(snapper\ create\ -t\ pre\ -p\ -d\ '${tmp.snapper_desc}')"
# If "tmp.snapper_pre_number" exists, create the post snapshot and clear the tmp variables.
post_transaction::::/usr/bin/sh -c [\ -n\ "${tmp.snapper_pre_number}"\ ]\ &&\ snapper\ create\ -t\ post\ --pre-number\ "${tmp.snapper_pre_number}"\ -d\ "${tmp.snapper_desc}";\ echo\ tmp.snapper_pre_number\ ;\ echo\ tmp.snapper_desc
EOF
fi

sudo snapper -c root list 2>/dev/null | grep -q "Post-install baseline" || \
  sudo snapper -c root create -d "Post-install baseline" || true

# NOTE: this gives you timeline + per-transaction snapshots and easy restores
# (Btrfs Assistant, or 'snapper undochange'). Snapshots are NOT backups (same
# disk), and one-command boot-into-snapshot rollback on stock Fedora needs
# extra plumbing (grub-btrfs) — add later if you ever want it.

# ----------------------------------------------------- quality-of-life glue
step "Quality-of-life glue"
# (Ghostty's own bundled extension provides the Files "Open in Ghostty" entry —
#  no nautilus-open-any-terminal gsettings needed.)
# Let your user drive the tailscale CLI without sudo (and makes Taildrop easy)
sudo tailscale set --operator="$USER" || true

# --------------------------------------------------------- firewall hardening
step "Firewall: stricter FedoraServer zone (default-deny inbound)"
# Workstation's default zone deliberately allows all inbound ports >1024.
# Fine at home; not what you want on cafe/hotel Wi-Fi. FedoraServer denies
# inbound by default; re-adding mdns keeps printer/cast discovery working.
# If something LAN-y ever breaks:  sudo firewall-cmd --add-service=<svc> --permanent
# Full revert:                     sudo firewall-cmd --set-default-zone=FedoraWorkstation
sudo firewall-cmd --permanent --zone=FedoraServer --add-service=mdns >/dev/null
sudo firewall-cmd --set-default-zone=FedoraServer
sudo firewall-cmd --reload
# (Tailscale traffic is unaffected — tailscaled manages its own rules.)

# ----------------------------------------------------------- monthly scrub
step "Monthly Btrfs scrub (verifies checksums of ALL data, not just what you read)"
if systemctl list-unit-files 'btrfs-scrub@.timer' 2>/dev/null | grep -q btrfs-scrub; then
  sudo systemctl enable --now 'btrfs-scrub@-.timer'   # '-' = systemd-escaped "/"
else
  echo "  btrfs-scrub timer unit not found — enable monthly scrubs in Btrfs Assistant instead."
fi

# ---------------------------------------------------------------------- keyd
step "keyd + Copilot-key remap (Shift+Super+F23 -> F13)"
# keyd isn't in Fedora repos and the COPRs were unreliable for F44, so build
# from source (tiny; deps gcc/make/git are installed above).
if ! command -v keyd >/dev/null 2>&1; then
  ktmp="$(mktemp -d)"
  git clone --depth=1 https://github.com/rvaiya/keyd "$ktmp/keyd" \
    && make -C "$ktmp/keyd" && sudo make -C "$ktmp/keyd" install
  rm -rf "$ktmp"
fi
# The Copilot key emits leftshift+leftmeta+f23; mapping just 'f23' is the robust
# form (nothing else sends F23, so the modifiers passing through are harmless).
sudo mkdir -p /etc/keyd
if [[ ! -f /etc/keyd/default.conf ]]; then
  sudo tee /etc/keyd/default.conf >/dev/null <<'EOF'
[ids]
*

[main]
f23 = f13
EOF
fi
sudo systemctl enable --now keyd 2>/dev/null || true
sudo keyd reload 2>/dev/null || true
# Verify: 'sudo keyd monitor' then press the key (should emit f13). Then bind
# F13 in Settings -> Keyboard -> Custom Shortcuts to whatever you want.

# ------------------------------------------------------------- boot and login
step "Boot & login behavior"
# Hide GRUB on healthy single-OS boots (menu still appears after a failed boot)
sudo grub2-editenv - set menu_auto_hide=1

# Autologin: boot flow becomes  LUKS passphrase -> desktop.
# GDM still demands your password for lock screen / logout.
if ! sudo grep -q '^\[daemon\]' /etc/gdm/custom.conf; then
  printf '\n[daemon]\n' | sudo tee -a /etc/gdm/custom.conf >/dev/null
fi
if ! sudo grep -q '^AutomaticLoginEnable' /etc/gdm/custom.conf; then
  sudo sed -i "/^\[daemon\]/a AutomaticLoginEnable=True\nAutomaticLogin=${USER}" \
    /etc/gdm/custom.conf
fi

# --------------------------------------------------------------------- shell
step "Default shell -> zsh"
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
  sudo usermod --shell "$(command -v zsh)" "$USER"
fi
# Zap (zsh plugin manager) — NOT run automatically: its installer is interactive
# and appends a line to ~/.zshrc, which would fight your stowed dotfiles. Run it
# by hand AFTER stowing, then add your plugins. The official one-liner is:
#   zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
# (If your .zshrc already sources zap via your dotfiles, skip this entirely.)

# ---------------------------------------------------------------------- done
step "Done — manual follow-ups"
echo
echo "Public keys to add to your forges:"
echo "--- GitHub  -> https://github.com/settings/keys"
cat "$HOME/.ssh/id_ed25519_github.pub"
echo "--- Codeberg -> https://codeberg.org/user/settings/keys"
cat "$HOME/.ssh/id_ed25519_codeberg.pub"

cat <<'EON'

  1. Reboot (new kernel/firmware, autologin, shell change, GNOME extensions).
  2. Tailscale SSH (your remote-access method):
       sudo tailscale up --ssh        # authenticates in a browser, one time
     This makes SSH work over the tailnet with no open ports and no sshd.
     Then from your phone/laptop:  ssh <user>@x1carbon
  3. Insync: launch it, sign in to Google, choose the sync folder and which
     Drive folders to sync (see the cloud-sync section above for the symlink tip).
  4. Autologin caveat: the GNOME login keyring stays locked since PAM never
     sees your password. Open the Passwords app (Seahorse) and set the Login
     keyring password to blank — it lives inside LUKS, so this is fine.
  5. Settings -> System -> Users: confirm Automatic Login shows enabled.
     Settings: enroll your fingerprint (works for sudo/unlock, never LUKS).
  6. 1Password: sign in, enable browser integration + system-auth unlock.
     Firefox: sign into Sync to restore uBlock, 1Password, Zotero add-ons.
  7. WinApps: git clone the repo and run its setup.sh — podman, podman-compose
     and freerdp are already in place. Verify /dev/kvm exists. Set
     WAFLAVOR="podman" in ~/.config/winapps/winapps.conf.
  8. Stow your dotfiles (zsh, starship, nvim, tmux, ghostty, git), then install
     Zap by hand (see shell section) if your .zshrc expects it.
  9. Verify hardware video decode with: vainfo
     Verify snapshots after your next dnf install with: sudo snapper -c root list
 10. Classic sshd is installed but NOT enabled — leave it off; Tailscale SSH
     (step 2) is your remote access. To use classic SSH instead, you'd run
     'sudo systemctl enable --now sshd' (and open the port), but you don't need to.
 11. LUKS insurance (deliberately manual): store the disk passphrase in
     1Password, then back up the header and move the file OFF this machine:
       sudo cryptsetup luksHeaderBackup <luks-partition> \
         --header-backup-file x1carbon-luks-header.img
     The file is sensitive — treat it like a key, not like a backup.
 12. Real backups (deliberately manual): pick a destination (USB disk, cheap
     storage box) and set up restic/borgmatic or Deja Dup. Sync != backup.
 13. Wallpapers (manual; belongs in your dotfiles): clone theme packs into
     ~/Pictures/Wallpapers/<theme> (catppuccin/wallpapers,
     AngelJumbo/gruvbox-wallpapers, linuxdotexe/nordic-wallpapers, dharmx/walls).
     Drive them via themeSwitcher or gsettings — GNOME's picker is flat-only.
 14. DankMaterialShell / Niri (excluded by choice): install via their COPRs
     (avengemedia:dms + danklinux, yalter:niri) when wanted. If DMS becomes your
     shell, let matugen own theming, or DMS_DISABLE_MATUGEN=1 to keep static
     themes from themeSwitcher. Don't run two theming engines at once.
EON
