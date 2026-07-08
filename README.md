# Codex Patches

A community-maintained patch queue and patched binary distribution for OpenAI Codex.

> Warning: Unofficial, not affiliated with OpenAI.

`codex-fixes` maintains a small, auditable patch layer on top of upstream [`openai/codex`](https://github.com/openai/codex). The intent is to publish temporary bug-fix builds quickly, then remove patches once the fixes land upstream.

This repository is open source under the same license as upstream Codex. At the time of writing, upstream `openai/codex` is licensed under Apache License 2.0.

## What This Project Is

- A public patch queue for funded Codex bug fixes.
- An automated binary distribution that rebuilds Codex when upstream publishes a new release.
- A temporary maintenance layer intended to shrink over time as fixes are accepted upstream.

## What This Project Is Not

- Not an official OpenAI repository.
- Not a general-purpose fork.
- Not a venue for drive-by issue filing or unpaid support.
- Not a repository that accepts pull requests.

Developers who want to contribute code should maintain their own fork, privately or publicly, and carry their own patches.

## How Bounties Work

Public bug-fix work is funded through Polar.sh because it supports open-source issue funding and bounties.

- Customers can fund an issue through Polar.sh.
- Bounty payment funds engineering work, not exclusive ownership of the fix.
- All funded fixes are released publicly in this repository.
- If a fix is infeasible, out of scope, or cannot be completed, the bounty may be refunded.
- The maintainer only replies to issues that have an active bounty, a serious funding inquiry, or a professional-services request.

Polar: `TODO_POLAR_URL`

## How To Request A Price Estimate

For private or professional engagements: “Contact the maintainer for a quote.”

Use this path when you need private triage, custom patching, support terms, SLA terms, or a scoped engineering engagement.

## How To Fund An Issue

1. Open a funded bug or quote-request issue using the provided template.
2. Add the Polar.sh funding link or explain the funding status.
3. Wait for maintainer review if the issue is funded, quote-related, or otherwise maintainer-approved.

Unfunded issues may be closed automatically with a polite explanation of the policy.

## How Professional Services Work

Professional services are handled separately from public bounty work.

- Additional warranties, support terms, SLA commitments, or expanded liability coverage are available only by separate written agreement.
- Contact the maintainer for a quote.
- Public bounty work does not create exclusive access to a fix.

## How Releases Work

For every upstream Codex release, this repository publishes a corresponding patched release after:

1. Cloning upstream Codex at the release tag.
2. Applying all `patches/*.patch` files.
3. Running the relevant upstream checks and tests.
4. Building binaries for the same platforms as upstream, or a conservative fallback matrix where the upstream workflow depends on private runners or signing infrastructure.
5. Publishing binaries plus SHA256 checksums in a GitHub Release.

Release notes list:

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

## Supported Platforms

The current upstream Codex release workflows indicate these target families:

- Linux: `x86_64-unknown-linux-musl`, `aarch64-unknown-linux-musl`
- macOS: `x86_64-apple-darwin`, `aarch64-apple-darwin`
- Windows: `x86_64-pc-windows-msvc`, `aarch64-pc-windows-msvc`

This repository currently uses a conservative GitHub-hosted fallback matrix where upstream relies on custom runners or signing infrastructure. The maintainer should keep the matrix aligned with upstream release workflows as they change.

## Security / Trust Model

- Patch files are public and intended to be small, auditable, and removable.
- Each patch file should correspond to exactly one funded bug ID.
- Patches should be generated with `git format-patch`.
- Consumers should review patch diffs, workflow definitions, and release notes before trusting a binary.
- Security reports should follow [SECURITY.md](SECURITY.md).

## Liability / Warranty Disclaimer

This repository is provided on an `AS IS` basis, without warranty.

- Liability is limited to the amount of the bounty paid for the specific issue.
- No warranty is provided, including merchantability, fitness for a particular purpose, or non-infringement, unless separately agreed in writing.
- No consequential damages, business interruption damages, lost profits, lost revenue, lost data, or similar damages are accepted.
- Professional services with additional protections are available separately by written agreement.

This summary is plain-language guidance, not legal advice. The maintainer should review these terms with a lawyer before relying on them.

## License

This project uses the same license as upstream Codex. See [LICENSE](LICENSE).

## Contact

- GitHub: [@cowwoc](https://github.com/cowwoc)
- Email: `cowwoc2020@gmail.com`
- Polar: `TODO_POLAR_URL`
