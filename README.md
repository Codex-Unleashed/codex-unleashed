# Codex Fixes

A public patch queue and patched binary distribution for OpenAI Codex.

> Warning: Unofficial, not affiliated with OpenAI.

[![License](https://img.shields.io/github/license/cowwoc/codex-fixes)](https://github.com/cowwoc/codex-fixes/blob/main/LICENSE)
[![Upstream bugs](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/cowwoc/codex-fixes/main/docs/badges/upstream-bugs.json)](https://github.com/cowwoc/codex-fixes/tree/main/patches/openai/codex)
[![Public fixes](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/cowwoc/codex-fixes/main/docs/badges/public-fixes.json)](https://github.com/cowwoc/codex-fixes/tree/main/patches)

## Quickstart

### Download a public patched release

Open the latest [GitHub Release](https://github.com/cowwoc/codex-fixes/releases/latest) and download the archive for your platform.

The exact filenames follow the published release artifacts for the current upstream build targets. In practice, pick the artifact matching your OS and architecture.

After extracting the archive, run the included `codex` binary the same way you would run upstream Codex.

## Get A Fix Faster

- Public release: use the latest [GitHub Release](https://github.com/cowwoc/codex-fixes/releases/latest).
- Early access: buyers can receive completed fixes up to 30 days before public release.
- New fix request: open an issue and describe the bug, scope, and business impact.
- Quote request: contact the maintainer directly for private or larger commercial work.

## Why This Exists

- Important user-facing issues can take months to be fixed upstream, even when they are time-sensitive for real users and teams.
- This project bridges that gap by shipping small, targeted fixes for issues that matter to users now, not months later.
- Patches stay public, auditable, and temporary: they are carried here until the equivalent fix lands upstream, then removed.
- Buyers can get early access to completed patched builds before those fixes roll into the public release.

## What To Expect

- Reviewed fixes only.
- No pull requests.
- No unpaid support queue.

## Early Access Policy

Users who pay for early access receive downloadable builds containing completed fixes up to 30 days before public release.

- You only pay once a completed downloadable build is ready.
- Any fix sold through early access is added to the public release no later than 30 days after first customer delivery.
- Full terms: [Commercial Terms](docs/COMMERCIAL_TERMS.md)

Polar: `TODO_POLAR_URL`

## How Releases Work

For every upstream Codex release, this repository publishes a corresponding patched release after applying the active patch queue, running the relevant checks, and rebuilding release artifacts.

Every release notes page lists:

- Upstream Codex version/tag
- Patch files applied
- Upstream commit SHA
- Build date
- Supported platforms
- Checksums

## Versioning

Patched releases append a patch release number to the upstream version:

- Upstream `1.3.6` -> patched `1.3.6.0`
- Second patched rebuild -> `1.3.6.1`

The `.0` release is the first patched build for that upstream version. Higher suffixes are rebuilds or subsequent patched republish events for the same upstream version.

## Policies

- Commercial terms: [docs/COMMERCIAL_TERMS.md](docs/COMMERCIAL_TERMS.md)
- Support policy: [SUPPORT.md](SUPPORT.md)
- Security policy: [SECURITY.md](SECURITY.md)
- Patch queue rules: [patches/README.md](patches/README.md)

## License

This project uses the same license as upstream Codex. See [LICENSE](LICENSE).

## Contact

- GitHub: [@cowwoc](https://github.com/cowwoc)
- Email: `cowwoc2020@gmail.com`
- Polar: `TODO_POLAR_URL`
