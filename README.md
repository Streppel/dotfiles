# dotfiles

Hyprland desktop on Arch. Super is the mod key, Kanagawa waybar, kitty, zsh.

Previously this repo was i3 on a Dell XPS 13 (2023). That tree is gone from `master`.

## New machine

```sh
sudo pacman -S --needed git base-devel
# install yay if you do not have it
git clone https://github.com/Streppel/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh
```

`install.sh` installs the package lists, oh-my-zsh plugins, and symlinks configs from this repo into `$HOME`. Existing files are renamed `*.bak-<timestamp>`, not overwritten.

Then enable greetd / NetworkManager / bluetooth (see the script epilogue), log out, log in.

## Layout

| path | what |
|---|---|
| `.zshrc` | oh-my-zsh lambda, fzf-tab, autosuggestions, mcfly, zoxide, eza/bat |
| `.config/hypr/` | Hyprland + hyprlauncher + hyprtoolkit (Kanagawa) + hyprsunset |
| `.config/waybar/` | statusline + `scripts/gpu.sh` |
| `.config/kitty/` | JetBrainsMono NF + JoyPixels |
| `.config/btop/` | gruvbox |
| `packages/` | pacman / AUR / optional extras |

Not tracked on purpose: browsers, Steam, Anytype data, SSH/GPG keys, git identity, history, wallpapers.

## Binds (short)

- `Super+T` terminal · `Super+Q` kill · `Super+E` files · `Super+W` firefox
- `Super+Space` hyprlauncher · `Super+L` lock (`hyprlock` if installed)
- `Super+Tab` / `Shift+Tab` next/prev workspace
- `Print` region to clipboard · `Shift+Print` full · `Super+Print` file + clipboard
- Click waybar mem/cpu/temp → btop · gpu → nvtop · disk → thunar

## Machine-specific (this desktop)

Edit these on another box:

- **Keyboard:** `kb_layout = br` in `hyprland.conf`
- **CPU temp:** waybar `temperature.hwmon-path-abs` is Ryzen k10temp (`0000:00:18.3`). Point it at the right hwmon or drop the path to let waybar guess.
- **GPU module:** `waybar/scripts/gpu.sh` looks for PCI id `1002:7550` (RX 9070 XT). Change `pci_id` or ignore the `GPU n/a` cell.
- **Intel leftovers:** this machine still has some Intel/NVIDIA packages installed from older hardware. They are **not** in `packages/pacman.txt`.

## Useful from the old i3 repo

Kept / ported:

- Super+W browser, Super+Tab workspaces, numpad workspaces
- Workspace routing: kitty 1, firefox 2, GoLand 3, Anytype 4, Telegram 5, Spotify 9
- Polkit agent on login, floating pavucontrol
- Night color (now hyprsunset, not redshift)

Dropped on purpose: XPS screenlayout/`xrandr`, i3/i3blocks/picom/rofi, Todoist capture, asdf, timewarrior, dual-monitor eDP+DP3 layout, `config` bare-git alias.

## Optional packages

See `packages/optional.txt` (GoLand, RustRover, Brave, Spotify, Steam, Anytype, grok, ollama, …).
