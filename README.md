# Codex Fixes

A community-maintained patch queue and patched binary distribution for OpenAI Codex.

> Warning: Unofficial, not affiliated with OpenAI.

`codex-fixes` maintains a small, auditable patch layer on top of upstream [`openai/codex`](https://github.com/openai/codex). The intent is to publish temporary bug-fix builds quickly, then remove patches once the fixes land upstream.

This repository is open source under the same license as upstream Codex. At the time of writing, upstream `openai/codex` is licensed under Apache License 2.0.

## What This Project Is

- A public patch queue for reviewed Codex bug fixes.
- An automated binary distribution that rebuilds Codex when upstream publishes a new release.
- A temporary maintenance layer intended to shrink over time as fixes are accepted upstream.
- A source of completed downloadable patch files and patched binaries for OpenAI Codex.

## What This Project Is Not

- Not an official OpenAI repository.
- Not a general-purpose fork.
- Not a venue for drive-by issue filing or unpaid support.
- Not a repository that accepts pull requests.

Developers who want to contribute code should maintain their own fork, privately or publicly, and carry their own patches.

## How Early Access Works

Public bug-fix work starts with review, scope approval, and non-binding buyer interest. Payment is only collected after a completed downloadable early-access build is ready for immediate delivery.

- New issues start as review requests, not payment requests.
- The maintainer reviews the issue, confirms scope, and signs off on the definition of done before considering implementation here.
- Interested buyers may comment `I am interested in purchasing early access at the specified price` to signal non-binding interest.
- No payment is collected unless and until an early-access build containing the fix is complete and available for immediate delivery.
- Once complete, the maintainer may create a dedicated Polar checkout link or invoice for early-access delivery.
- Buyers receive immediate access to an early-access build containing the completed fix they purchased, up to 30 days before public release.
- Early-access builds may also contain other unreleased fixes.
- Payment buys early access to a completed build containing the requested fix, not exclusive ownership of any specific preview build contents.
- Customers are purchasing immediate access to completed downloadable software artifacts, not consulting services, sponsorships, or crowdfunding access.
- Each purchased fix is added to the public release no later than 30 days after first customer delivery of that fix.
- If an early-access build is purchased, the resulting fix is ultimately released publicly in this repository.
- If a completed early-access build is infeasible, out of scope, or cannot be delivered responsibly, no payment is collected for that build.
- The maintainer only replies to issues that have credible buyer interest, a serious purchase inquiry, or a professional-services request.

Polar: `TODO_POLAR_URL`

## How To Request A Price Estimate

For private or professional engagements: “Contact the maintainer for a quote.”

Use this path when you need private triage, custom patching, support terms, SLA terms, or a scoped engineering engagement.

## How To Request Early Access

1. Open an issue request or quote-request issue using the provided template.
2. Wait for maintainer review and scope approval.
3. If you want to signal non-binding interest, comment `I am interested in purchasing early access at the specified price`.
4. If the maintainer completes an early-access build containing that fix, use the maintainer-provided Polar checkout link or invoice to purchase immediate access to the downloadable build.

Issues without credible buyer interest may be closed automatically with a polite explanation of the policy.

## How Professional Services Work

Professional services are handled separately from public early-access builds.

- Additional warranties, support terms, SLA commitments, or expanded liability coverage are available only by separate written agreement.
- Contact the maintainer for a quote.
- Early-access purchases do not create exclusive access to a fix or to every other unreleased fix that may appear in the same preview build.
- For larger company engagements, the maintainer may prefer Polar invoice or quote-aligned billing after scope approval.

## How Releases Work

For every upstream Codex release, this repository publishes a corresponding patched release after:

1. Cloning upstream Codex at the release tag.
2. Applying all patch files under `patches/<owner>/<repo>/issue-<number>/`.
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
- Each issue directory is repository-relative, for example `patches/openai/codex/issue-1234/`.
- Patches should be generated with `git format-patch`.
- Consumers should review patch diffs, workflow definitions, and release notes before trusting a binary.
- Security reports should follow [SECURITY.md](SECURITY.md).

## Liability / Warranty Disclaimer

This repository is provided on an `AS IS` basis, without warranty.

- Liability is limited to the amount paid for the specific early-access build or related professional-services engagement.
- No warranty is provided, including merchantability, fitness for a particular purpose, or non-infringement, unless separately agreed in writing.
- No consequential damages, business interruption damages, lost profits, lost revenue, lost data, or similar damages are accepted.
- Professional services with additional protections are available separately by written agreement.
- Payment processor, merchant-of-record, refund, and chargeback fees may reduce or eliminate the amount retained by the maintainer even when a payment is later refunded.

This summary is plain-language guidance, not legal advice. The maintainer should review these terms with a lawyer before relying on them.

## License

This project uses the same license as upstream Codex. See [LICENSE](LICENSE).

## Contact

- GitHub: [@cowwoc](https://github.com/cowwoc)
- Email: `cowwoc2020@gmail.com`
- Polar: `TODO_POLAR_URL`
