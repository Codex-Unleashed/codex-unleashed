# Codex Fixes

A community-maintained patch queue and patched binary distribution for OpenAI Codex.

> Warning: Unofficial, not affiliated with OpenAI.

[![Releases](https://img.shields.io/github/v/release/cowwoc/codex-fixes?display_name=tag)](https://github.com/cowwoc/codex-fixes/releases)
[![License](https://img.shields.io/github/license/cowwoc/codex-fixes)](https://github.com/cowwoc/codex-fixes/blob/main/LICENSE)
[![Public fixes](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/cowwoc/codex-fixes/main/docs/badges/public-fixes.json)](https://github.com/cowwoc/codex-fixes/tree/main/patches)
[![Early-Access fixes](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/cowwoc/codex-fixes/main/docs/badges/early-access-fixes.json)](https://github.com/cowwoc/codex-fixes/issues)

## Quickstart

### Download a public patched release

Open the latest [GitHub Release](https://github.com/cowwoc/codex-fixes/releases/latest) and download the archive for your platform.

The exact filenames follow the published release artifacts for the current upstream build targets. In practice, pick the artifact matching your OS and architecture.

After extracting the archive, run the included `codex` binary the same way you would run upstream Codex.

## Why This Exists

- `codex-fixes` maintains a small, auditable patch layer on top of upstream [`openai/codex`](https://github.com/openai/codex).
- The intent is to publish temporary bug-fix builds quickly, then remove patches once the fixes land upstream.
- This repository is open source under the same license as upstream Codex. At the time of writing, upstream `openai/codex` is licensed under Apache License 2.0.
- Upstream issues do not always get fixed on your timeline.
- This repository carries small, auditable Codex fixes until upstream absorbs them.
- Buyers can get early access to completed patched builds before those fixes roll into the public release.

## What To Expect

- Reviewed fixes only.
- No pull requests.
- No unpaid support queue.
- Public patch files and public release notes.
- Temporary fixes with the goal of eventual upstream removal.

## Early Access Policy

Users who pay for early access receive downloadable builds containing completed fixes up to 30 days before public release.

- You only pay once a completed downloadable build is ready.
- Early-access builds may also contain other unreleased fixes, so early access is not exclusive to a single patch.
- Any fix sold through early access is added to the public release no later than 30 days after first customer delivery.
- Serious purchase inquiries and larger commercial requests are handled directly by the maintainer.

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

## Professional Services

Custom commercial work is handled separately from public early-access builds.

- Additional warranties, support terms, SLA commitments, or expanded liability coverage are available only by separate written agreement.
- Contact the maintainer for a quote.
- Early-access purchases do not create exclusive access to a fix or to every other unreleased fix that may appear in the same preview build.
- For larger company engagements, the maintainer may prefer Polar invoice or quote-aligned billing after scope approval.

## Liability / Warranty Disclaimer

This repository is provided on an `AS IS` basis, without warranty.

- Liability is limited to the amount paid for the specific early-access build or related separate commercial engagement.
- No warranty is provided, including merchantability, fitness for a particular purpose, or non-infringement, unless separately agreed in writing.
- No consequential damages, business interruption damages, lost profits, lost revenue, lost data, or similar damages are accepted.
- Additional protections are available only by separate written agreement.
- Payment processor, merchant-of-record, refund, and chargeback fees may reduce or eliminate the amount retained by the maintainer even when a payment is later refunded.

This summary is plain-language guidance, not legal advice. The maintainer should review these terms with a lawyer before relying on them.

## License

This project uses the same license as upstream Codex. See [LICENSE](LICENSE).

## Contact

- GitHub: [@cowwoc](https://github.com/cowwoc)
- Email: `cowwoc2020@gmail.com`
- Polar: `TODO_POLAR_URL`
