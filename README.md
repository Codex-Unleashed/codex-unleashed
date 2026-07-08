# Codex Fixes

A community-maintained patch queue and patched binary distribution for OpenAI Codex.

> Warning: Unofficial, not affiliated with OpenAI.

`codex-fixes` maintains a small, auditable patch layer on top of upstream [`openai/codex`](https://github.com/openai/codex). The intent is to publish temporary bug-fix builds quickly, then remove patches once the fixes land upstream.

This repository is open source under the same license as upstream Codex. At the time of writing, upstream `openai/codex` is licensed under Apache License 2.0.

## Why This Exists

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

Completed fixes may be offered first through Polar as downloadable early-access builds.

- Payment is only collected after a completed downloadable build is ready for immediate delivery.
- Buyers receive access to an early-access build containing the purchased fix up to 30 days before public release.
- Early-access builds may also contain other unreleased fixes.
- Customers are purchasing immediate access to completed downloadable software artifacts.
- Each purchased fix is added to the public release no later than 30 days after first customer delivery of that fix.
- The maintainer only replies to issues that have credible buyer interest, a serious purchase inquiry, or a separate commercial inquiry.

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
