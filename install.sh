#!/usr/bin/env bash
# Bootstrap this machine from the repo. Safe to re-run.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES="$DOTFILES/packages"

need() { command -v "$1" >/dev/null 2>&1; }

pkg_list() {
  grep -vE '^\s*(#|$)' "$1"
}

echo "==> packages (pacman)"
sudo pacman -S --needed --noconfirm $(pkg_list "$PACKAGES/pacman.txt")

if ! need yay; then
  echo "==> install yay"
  tmp="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm --needed)
  rm -rf "$tmp"
fi

echo "==> packages (AUR)"
yay -S --needed --noconfirm $(pkg_list "$PACKAGES/aur.txt")

echo "==> oh-my-zsh + plugins"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

clone_plugin() {
  local dest="$HOME/.oh-my-zsh/custom/plugins/$1"
  local url="$2"
  if [[ ! -d "$dest" ]]; then
    git clone --depth 1 "$url" "$dest"
  fi
}

clone_plugin fzf-tab                 https://github.com/Aloxaf/fzf-tab
clone_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
clone_plugin zsh-completions         https://github.com/zsh-users/zsh-completions

echo "==> symlink configs"
link() {
  local rel="$1"
  local src="$DOTFILES/$rel"
  local dst="$HOME/$rel"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ "$(readlink -f "$dst" 2>/dev/null || true)" == "$(readlink -f "$src")" ]]; then
      return 0
    fi
    mv "$dst" "$dst.bak-$(date +%Y%m%d-%H%M%S)"
  fi
  ln -s "$src" "$dst"
}

link .zshrc
link .config/hypr/hyprland.conf
link .config/hypr/hyprlauncher.conf
link .config/hypr/hyprtoolkit.conf
link .config/hypr/hyprsunset.conf
link .config/hypr/scripts/screenshot.sh
link .config/hypr/scripts/ocr.sh
link .config/tensaku/config.toml
link .config/waybar/config.jsonc
link .config/waybar/modules.jsonc
link .config/waybar/style.css
link .config/waybar/themes/kanagawa.css
link .config/waybar/scripts/gpu.sh
link .config/kitty/kitty.conf
link .config/btop/btop.conf
link .config/mimeapps.list
chmod 755 "$DOTFILES/.config/waybar/scripts/gpu.sh" \
  "$DOTFILES/.config/hypr/scripts/screenshot.sh" \
  "$DOTFILES/.config/hypr/scripts/ocr.sh"

if ! need br; then
  echo "==> broot shell function (optional: run 'broot --install' later)"
fi

if [[ "$SHELL" != *zsh ]]; then
  echo "==> chsh to zsh"
  chsh -s "$(command -v zsh)" || echo "    chsh failed; run it yourself"
fi

mkdir -p "$HOME/Pictures" "$HOME/code"

cat <<'EOF'

Done.

Next (once, as root-ish):
  systemctl enable --now NetworkManager
  systemctl enable --now bluetooth
  systemctl enable greetd        # tuigreet -> start-hyprland

Git identity is not in this repo. Set it:
  git config --global user.name  "..."
  git config --global user.email "..."

Hardware notes in README.md (GPU PCI id, CPU hwmon path, keyboard layout).
EOF
