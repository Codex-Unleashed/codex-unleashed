# Patch Queue

Each patch in this directory must:

- be generated with `git format-patch`
- be named with the funded bug ID
- correspond to exactly one logical bug fix
- remain small, auditable, and removable

Recommended naming format:

- `1234-fix-title.patch`
- `bug-1234-fix-title.patch`

Operational rules:

- one funded bug ID per patch file
- no multi-issue rollups
- remove the patch once upstream ships the fix
- keep the patch history easy to review against upstream
