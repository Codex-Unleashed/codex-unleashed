# Patch Queue

Patch layout:

- `patches/<owner>/<repo>/issue-<number>/README.md`
- `patches/<owner>/<repo>/issue-<number>/0001-<short-slug>.patch`

Examples:

- `patches/openai/codex/issue-1234/README.md`
- `patches/openai/codex/issue-1234/0001-fix-crash-on-startup.patch`
- `patches/cowwoc/codex-fixes/issue-12/README.md`
- `patches/cowwoc/codex-fixes/issue-12/0001-fix-release-notes.patch`

Operational rules:

- one issue directory per repository-relative GitHub issue
- each issue directory must contain a human-readable `README.md`
- patches should be generated with `git format-patch`
- each patch should correspond to one logical bug fix
- prefer `0001-<short-slug>.patch` over `change.patch`
- no multi-issue rollups
- remove the patch once upstream ships the fix
- keep the patch history easy to review against upstream

Security / trust model:

- patch files are public and intended to be small, auditable, and removable
- each issue directory is repository-relative, for example `patches/openai/codex/issue-1234/`
- consumers should review patch diffs, workflow definitions, and release notes before trusting a binary
- security reports should follow [SECURITY.md](../SECURITY.md)

Why `0001-<short-slug>.patch`:

- it stays readable in release notes and logs
- it matches `git format-patch` output naturally
- it leaves room for a small patch series later if an issue truly needs it

Issue directory `README.md` should include:

- canonical issue reference, for example `openai/codex#1234`
- patch intent and scope
- reproduction summary
- upstream status or related links
