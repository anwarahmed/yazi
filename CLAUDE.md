# Yazi Config — Customizations & Change Log

This file documents all differences between the active config files and their
`*-default.toml` counterparts, plus installed plugins. Update it whenever a
setting changes.

**Config style:** `yazi.toml` and `keymap.toml` contain *only* the deltas from
Yazi's built-in preset. Yazi merges the user config over the preset, so anything
not listed keeps its default value. Do **not** paste the full default file back
in — that is what caused config drift on past upgrades. The `*-default.toml`
files are kept purely as an unmodified reference copy of the preset.

---

## yazi.toml

| Setting | Default | Custom | Reason |
|---|---|---|---|
| `[mgr] ratio` | `[1, 4, 3]` | `[1, 2, 4]` | Wider preview pane |
| `[mgr] show_hidden` | `false` | `true` | Show hidden files by default |
| `[plugin] prepend_fetchers` | _(absent)_ | git fetchers added | Git status integration |

Full `prepend_fetchers` block added:
```toml
prepend_fetchers = [
  { url = "*",  run = "git", group = "git" },
  { url = "*/", run = "git", group = "git" },
]
```

---

## keymap.toml

Both bindings live in a single `prepend_keymap` under `[mgr]`, which takes
priority over the preset bindings.

| Key | Default | Custom | Reason |
|---|---|---|---|
| `<Enter>` (mgr) | `open` | `plugin smart-enter` | Navigate into dirs, open files |
| `l` (mgr) | `enter` | `plugin smart-enter` | Same behaviour on the vim-style key |

---

## theme.toml

Entire file is a customization — not present in defaults. Sets the active flavor
and the git status signs:

```toml
[flavor]
use = "onedark"

[git]
modified_sign  = "   modified"
added_sign     = "      added"
untracked_sign = "  untracked"
ignored_sign   = "    ignored"
deleted_sign   = "    deleted"
updated_sign   = "    updated"
```

The signs live here rather than in `init.lua` because this is the location the
git plugin documents, and because the plugin re-reads `th.git` on theme reloads —
values assigned imperatively at startup would not survive one.

Note: `[git]` is a plugin-specific section, so Yazi does **not** validate its
keys. A typo fails silently rather than erroring.

### Folder icons

`[icon] prepend_globs` gives `~/Developer` and `~/Work` their own icons:

```toml
[icon]
prepend_globs = [
  { url = "/{home,Users}/*/Developer/", text = "", fg = "#00bcd4" },
  { url = "/{home,Users}/*/Work/",      text = "", fg = "#00bcd4" },
]
```

Two things make these sit with the preset's own folder icons rather than beside
them:

- **Colour.** `#00bcd4` is what the preset gives every standard home folder —
  Documents, Downloads, Music, Pictures, Videos all use it (see the `dirs` block
  in `theme-dark.toml`).
- **Outline, not filled.** The preset's home-folder glyphs are all line art of a
  similar stroke weight. Most "tools" and "briefcase" glyphs in Nerd Fonts are
  solid fills (`fa-screwdriver_wrench` U+EF70, `md-tools` U+F1064,
  `fa-briefcase` U+F0B1) and read as heavy blobs next to them. `cod-tools`
  (U+EB6D, wrench + screwdriver) and `oct-briefcase` (U+F491) are the outline
  equivalents. `oct-briefcase` is literally the same family as Documents
  (U+F401), Downloads (U+F498) and Videos (U+F447), so its stroke weight matches
  exactly.

Icon family does not need to be uniform — the preset mixes Octicons, FontAwesome
and Codicons freely and picks per meaning. Colour and fill style are the parts
that have to stay consistent.

Don't pick these by codepoint from memory. Nerd Fonts glyph names are indexed in
[`glyphnames.json`][glyphnames] upstream; grep that for candidates, then *render
them and look* before committing to one — several plausible-looking names are
unrelated icons (`cod-tools` sounds like `EAE7`, which is actually an eye-slash),
and fill vs. outline is invisible in the config text:

```sh
magick -size 150x170 xc:'#1e222a' -font /usr/share/fonts/TTF/JetBrainsMonoNerdFont-Regular.ttf \
  -pointsize 90 -fill '#00bcd4' -gravity center -annotate 0 "$(python3 -c 'print(chr(0xEB6D))')" out.png
```

[glyphnames]: https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/glyphnames.json


`prepend_globs`, not `prepend_dirs`: a `dirs` rule keys off the bare folder name
and would icon *every* `Developer`/`Work` directory on disk. Globs match the full
path, and `Icon::matches` checks globs *before* `dirs`, so these win over the
preset regardless of ordering.

Three things about the pattern syntax (`yazi-config/src/pattern.rs`) are easy to
get wrong, and all three fail **silently** — the rule just never fires:

- **No `~` expansion.** `~/Developer/` is treated as a literal glob and matches
  nothing. The home path has to be spelled out.
- **The trailing `/` is what makes a pattern directory-only.** `Pattern` records
  `is_dir` from that slash and rejects on `is_dir != self.is_dir` *before*
  running the glob, so a dir rule without it can never match.
- **`*` does not cross `/`** (`literal_separator` is enabled whenever the pattern
  contains a slash), so `/{home,Users}/*/Developer/` matches exactly one path
  segment for the username — `/home/anwar/Developer`, not
  `/home/anwar/src/Developer`.

The `{home,Users}` alternate is what keeps this working on both machines:
`/home/<user>` on Arch, `/Users/<user>` on macOS. Matching is case-insensitive
unless the pattern is prefixed with `\s`.

The `theme-dark.toml` and `theme-light.toml` files are the yazi defaults and are
unchanged. `theme.toml` overrides the flavor, the git signs, and these icons.

---

## vfs.toml

Removed — it was byte-identical to `vfs-default.toml` and therefore contributed
nothing. Yazi runs fine without it. `vfs-default.toml` is retained as reference.

---

## init.lua

Not a TOML config but customized. Loads the git plugin; the status signs it uses
are configured under `[git]` in `theme.toml`:

```lua
require("git"):setup()
```

---

## Installed Plugins

### git.yazi
- **Source:** `yazi-rs/plugins:git` rev `3f2b882`
- **Purpose:** Shows git status indicators next to files in the file list
- **Setup:** Loaded in `init.lua`; signs set under `[git]` in `theme.toml`
- **Config:** `prepend_fetchers` in `yazi.toml`

### smart-enter.yazi
- **Source:** `yazi-rs/plugins:smart-enter` rev `3f2b882`, managed by `ya pkg`
  (listed in `package.toml`)
- **Purpose:** Makes `<Enter>` navigate into directories and open files, rather
  than always invoking the opener
- **Setup:** Bound to `<Enter>` and `l` in `keymap.toml`
- **Plugin file:** `plugins/smart-enter.yazi/main.lua`

---

## Installed Flavors

| Flavor | Status | Source |
|---|---|---|
| `onedark` | **Active** | `BennyOe/onedark` rev `668d71d` |

To switch flavor, change `use = "..."` in `theme.toml`.

---

## Multi-Machine Setup (macOS + Omarchy)

This config is shared between a Mac (Homebrew) and an Omarchy/Arch machine, and
**the two are normally on different Yazi versions** — Homebrew tracks upstream
releases quickly while Arch lags. As of 2026-08-15: Homebrew `26.8.15`, Arch
`26.5.6`.

That skew is fine, and is the main reason `yazi.toml` / `keymap.toml` are kept as
deltas only: a delta config inherits each machine's own preset, so both get the
correct platform *and* version defaults automatically. Verified by loading this
config under real `26.5.6` and `26.8.15` binaries — clean on both.

Rules to keep it that way:

- **Never paste the full preset back into `yazi.toml` / `keymap.toml`.** A full
  copy pins one machine's version onto the other. The pre-2026-08-15 config did
  this, which silently cost the Mac the renamed `copy dirpath`, `backward wide`,
  and `forward wide` bindings — Yazi does not validate action names at load, so
  those keys just quietly stopped working rather than erroring.
- **Never override `[opener]`.** The preset already branches on
  `for = "linux"` / `for = "macos"`, so `xdg-open` vs `open` is handled upstream.
- **Minimum version: Yazi 26.5.6**, set by `git.yazi`, which declares
  `--- @since 26.5.6`. Both machines must be at or above this.
- **Run `ya pkg upgrade` from the machine with the *oldest* Yazi** (currently
  Arch), then commit. Plugins declare a minimum version via `@since`; upgrading
  from the newer machine can pull in a plugin the older one cannot run. Package
  hashes themselves are stable across `ya` versions — verified that `ya 26.8.15`
  and `ya 26.5.6` compute identical hashes — so `package.toml` will not
  ping-pong between machines.
- If `ya pkg` ever reports *"You have modified the contents of ..."* for a
  package you never edited, it is a stale hash in `package.toml`, not real local
  edits. Confirm with `git status`, then re-run with `--discard`.

The `*-default.toml`, `theme-dark.toml` and `theme-light.toml` files are
reference copies of the **26.5.6** preset. Yazi never loads them from the config
directory — only `theme.toml` is read — so they cannot break either machine, but
they do not describe the Mac's newer preset. For an accurate reference, read the
[`shipped`](https://github.com/sxyazi/yazi/tree/shipped/yazi-config/preset) tag
upstream, which always matches the current stable release.

---

## Verifying a Change

Don't reason about whether a config edit is valid — load it and look:

```sh
YAZI_CONFIG_HOME=$PWD timeout 8 yazi /tmp </dev/null 2>&1 | head
```

Without a TTY this always ends in `os error 6` (Linux) or `os error 25`; that is
the terminal failing, not the config. A real config problem prints a
`TOML parse error` and `Press <Enter> to continue with preset settings...`
*before* that line. Always re-run with a deliberately planted error — appending a
second `[mgr]` table is enough — to confirm the check actually discriminates
instead of passing vacuously.

What this check does **not** catch:

- **Invalid action names.** Yazi does not validate `run = "..."` at load time. A
  bogus action loads clean and only fails when the key is pressed. After any
  Yazi upgrade, verify bindings by pressing them, or by diffing
  `keymap-default.toml` against the new release.
- **`theme.toml` errors.** It is parsed after TTY init, so its errors never
  surface in this headless check. `[git]` is a plugin-specific section and is not
  validated at all — a typo in a sign name fails silently.

### Checking what actually rendered

For anything the headless check can't reach — `theme.toml`, icons, flavor colors —
drive Yazi in a pseudo-TTY and grep the frame it paints. `script` alone is not
enough: it hands Yazi a 0×0 window and Yazi draws an empty frame that greps clean
whatever you do. The window size has to be set on the pty **before** exec:

```python
master, slave = pty.openpty()
fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 45, 200, 0, 0))
subprocess.Popen(["yazi", target], stdin=slave, stdout=slave, stderr=slave,
                 env=dict(os.environ, YAZI_CONFIG_HOME=cfg, TERM="xterm-256color"))
```

Then strip the CSI/OSC escapes and inspect the codepoints around a filename.
Ignore the two `Terminal response timeout` warnings — nothing is there to answer
Yazi's capability queries, and it carries on and renders anyway.

Because this reads the real glyph rather than the config text, it catches the
silent failures nothing else does: a `[git]` sign typo, an icon rule that never
fires, a flavor that didn't load. Pair it with a *negative* case — render a
decoy directory the rule should **not** match and confirm the icon stays the
preset default. A scoped rule that matches nothing at all looks identical to a
working one if you only ever check the folder you expect to hit.

To test against the *other* machine's Yazi version without that machine, run its
release binary directly (the zip contains both `yazi` and `ya`):

```sh
curl -sSL -o y.zip https://github.com/sxyazi/yazi/releases/download/v<TAG>/yazi-x86_64-unknown-linux-gnu.zip
unzip -q y.zip && ./yazi-x86_64-unknown-linux-gnu/yazi --version
```

---

## Maintenance

```sh
ya pkg upgrade   # run on the OLDEST-Yazi machine, then commit package.toml
```

---

## Change Log

| Date | File | Change |
|---|---|---|
| 2026-05-14 | `keymap.toml` | `<Enter>` changed from `open` to `plugin smart-enter` |
| 2026-05-14 | `plugins/smart-enter.yazi/` | Added official smart-enter plugin |
| 2026-07-14 | `tmux.conf` | Removed stray/stale `tmux.conf` an Omarchy update dropped into this folder; it was an outdated subset of the live `~/.config/tmux/tmux.conf`, so no content was lost |
| 2026-08-15 | `yazi.toml`, `keymap.toml` | Reduced from full copies of the 26.5.6 preset to deltas only (~28KB → <1KB). Removes the stale `copy dirname` / `backward --far` bindings that would have broken on the 26.8.15 upgrade |
| 2026-08-15 | `keymap.toml` | Documented the previously undocumented `l` → `plugin smart-enter` binding |
| 2026-08-15 | `theme.toml`, `init.lua` | Moved git status signs from `init.lua` into `[git]` in `theme.toml` |
| 2026-08-15 | `package.toml`, `plugins/` | `ya pkg upgrade`: git `1db18bb` → `3f2b882` (theme-reload refresh, retryable-fetch fix), smart-enter rev bump (contents unchanged), onedark `fa1da70` → `668d71d` (README-only; refreshed a stale hash that was aborting upgrades) |
| 2026-08-15 | `flavors/flexoki-dark.yazi` | Removed unused inactive flavor |
| 2026-08-15 | `vfs.toml` | Removed; identical to the default and contributed nothing |
| 2026-08-15 | `.backup/` | Removed stale 2026-05-06 backup; git history serves this purpose |
| 2026-08-15 | `CLAUDE.md`, `README.md` | Documented the macOS + Omarchy split: version floor 26.5.6, `ya pkg upgrade` from the oldest-Yazi machine, and why the deltas-only style is what makes the Homebrew/Arch version skew safe |
| 2026-08-15 | `CLAUDE.md` | Added "Verifying a Change": how to tell a real config error from the headless no-TTY noise, what that check cannot catch (action names, `theme.toml`, `[git]`), and how to test against the other machine's Yazi version |
| 2026-08-16 | `theme.toml` | Added `[icon] prepend_globs` giving `~/Developer` ( `cod-tools`) and `~/Work` ( `oct-briefcase`) icons — outline glyphs in the preset's `#00bcd4` so they match the other home folders; scoped to the home dir by full-path glob so same-named folders elsewhere keep the preset icon |
| 2026-08-16 | `CLAUDE.md` | Added "Checking what actually rendered": driving Yazi in a pty with an explicit `TIOCSWINSZ` to verify `theme.toml`/icon changes the headless check cannot see, and why a negative case is required |
