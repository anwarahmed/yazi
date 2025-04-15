-- Setup Git Status Signs
th.git = th.git or {}
th.git.modified_sign = "✗  modified"
th.git.added_sign = "✚     added"
th.git.untracked_sign = "✭ untracked"
th.git.ignored_sign = "◌   ignored"
th.git.deleted_sign = "✗   deleted"
th.git.updated_sign = "   updated"

-- Load Git Integraiton Plugin
require("git"):setup()
