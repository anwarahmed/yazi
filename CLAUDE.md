# Yazi Config — Customizations & Change Log

This file documents all differences between the active config files and their
`*-default.toml` counterparts, plus installed plugins. Update it whenever a
setting changes.

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

| Key | Default | Custom | Reason |
|---|---|---|---|
| `<Enter>` (mgr) | `open` | `plugin smart-enter` | Navigate into dirs, open files |

---

## theme.toml

Entire file is a customization — not present in defaults. Sets the active flavor:

```toml
[flavor]
use = "onedark"
```

The `theme-dark.toml` and `theme-light.toml` files are the yazi defaults and are
unchanged. `theme.toml` overrides the flavor only.

---

## vfs.toml

No changes from default (both contain only `[services]` with no entries).

---

## init.lua

Not a TOML config but customized. Sets custom git status signs using nerd font
icons, then loads the git plugin:

```lua
th.git.modified_sign  = "   modified"
th.git.added_sign     = "      added"
th.git.untracked_sign = "  untracked"
th.git.ignored_sign   = "    ignored"
th.git.deleted_sign   = "    deleted"
th.git.updated_sign   = "    updated"

require("git"):setup()
```

---

## Installed Plugins

### git.yazi
- **Source:** `yazi-rs/plugins:git` rev `1db18bb`
- **Purpose:** Shows git status indicators next to files in the file list
- **Setup:** Loaded in `init.lua` with custom nerd font signs
- **Config:** `prepend_fetchers` in `yazi.toml`

### smart-enter.yazi
- **Source:** `yazi-rs/plugins` (official, installed manually)
- **Purpose:** Makes `<Enter>` navigate into directories and open files, rather
  than always invoking the opener
- **Setup:** Bound to `<Enter>` in `keymap.toml`
- **Plugin file:** `plugins/smart-enter.yazi/main.lua`

---

## Installed Flavors

| Flavor | Status | Source |
|---|---|---|
| `onedark` | **Active** | `BennyOe/onedark` rev `fa1da70` |
| `flexoki-dark` | Installed, inactive | `gosxrgxx/flexoki-dark` rev `3e8cfba` |

To switch flavor, change `use = "..."` in `theme.toml`.

---

## Change Log

| Date | File | Change |
|---|---|---|
| 2026-05-14 | `keymap.toml` | `<Enter>` changed from `open` to `plugin smart-enter` |
| 2026-05-14 | `plugins/smart-enter.yazi/` | Added official smart-enter plugin |
