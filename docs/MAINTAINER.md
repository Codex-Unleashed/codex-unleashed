# Maintainer Guide

## Add A New Funded Patch

1. Confirm the issue has an active bounty, a quote approval, or explicit maintainer approval.
2. Create the fix against a clean checkout of upstream `openai/codex`.
3. Create `patches/<owner>/<repo>/issue-<number>/`.
4. Add a `README.md` describing the issue reference, scope of the fix, and any upstream links.
5. Generate one or more patch files with `git format-patch` and store them in that directory.
6. Prefer `0001-<short-slug>.patch` naming over `change.patch`.
7. Update any issue labels such as `funded`, `quote-request`, `professional-services`, or `maintainer-approved` as needed.

## Test It

1. Run `scripts/apply-patches.sh <upstream-checkout>`.
2. Run `scripts/build-release.sh <upstream-checkout>`.
3. Run the GitHub Actions `ci.yml` workflow manually if you need an Actions-based confirmation.
4. Verify that release notes mention the upstream tag, upstream commit SHA, patch list, supported platforms, and checksums.
5. If upstream changed its CI or release pipeline, update the fallback commands and target matrix in this repository before publishing.

## Release Manually

1. Trigger `.github/workflows/upstream-release-check.yml` with `workflow_dispatch`.
2. Optionally provide an explicit upstream tag or patch release number through workflow inputs.
3. Review the created GitHub Release and uploaded artifacts before announcing availability.

## Remove A Patch After Upstream Fixes It

1. Confirm the fix is present in an upstream release or commit.
2. Remove the corresponding `patches/<owner>/<repo>/issue-<number>/` directory.
3. Re-run `ci.yml` to confirm remaining patches still apply cleanly.
4. Note the removal in the next release notes.

## Refunds And Quote Requests

- Refund bounties when the requested fix is infeasible, out of scope, blocked by upstream constraints, or otherwise cannot be completed responsibly.
- Keep quote requests out of public issue discussion when sensitive scope or commercial details are involved.
- For paid professional work with custom terms, use a separate written agreement covering support, warranty, SLA, and liability terms.

This document is operational guidance, not legal advice. Review customer-facing terms and refund handling with a lawyer before relying on them.
