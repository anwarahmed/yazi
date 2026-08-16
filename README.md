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
- `vfs-default.toml`
- `theme-dark.toml`
- `theme-light.toml`

`yazi.toml` and `keymap.toml` only contain the settings that differ from Yazi's
built-in preset; everything else falls back to the default. The `*-default.toml`
files above are unmodified reference copies of that preset, snapshotted at Yazi
**26.5.6** — Yazi never loads them from the config directory, so they are safe to
keep even on a machine running a newer release. For a reference that always
matches the current stable release, see the [`shipped`][shipped] tag upstream.

Because the config is deltas-only it is version- and platform-agnostic, which
matters here: this repo is shared between macOS and Omarchy, and Homebrew and
Arch are usually on different Yazi releases. Requires Yazi **26.5.6 or newer**
(the `git.yazi` plugin declares `@since 26.5.6`).

[shipped]: https://github.com/sxyazi/yazi/tree/shipped/yazi-config/preset

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
