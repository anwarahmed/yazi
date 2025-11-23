# yazi

https://yazi-rs.github.io/

My Yazi Setup

Copy the contents of this repository to `~/.config/yazi`.
The following files can be ignored:

- `README.md`
- `.git`
- `.gitignore`
- `yazi-default.toml`
- `keymap-default.toml`
- `theme-dark.toml`
- `theme-light.toml`

## macOS Homebrew

```shell
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font
```

## ArchLinux / Omarchy

```shell
sudo pacman -S yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick
```

## ZSH
Add the following to `~/.zshrc`:
```shell
# Yazi: `y` shell wrapper that provides the ability to change the current working directory when exiting Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
```
Add the following to `~/.zprofile`:
```shell
# Yazi
export EDITOR="nvim"
```

## Bash
Add the following to `~/.bashrc`:
```shell
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
```
