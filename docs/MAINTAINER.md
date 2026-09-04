# Maintainer Guide

## Add A New Patch

1. Review the issue and confirm the scope, definition of done, and whether this repository should carry the fix.
2. Publish the reviewed scope, estimated early-access price, and the buyer-interest comment text on the issue.
3. Do not publish a payment link until an early-access build containing the fix is complete and available for immediate delivery.
4. Confirm the issue has credible buyer interest, a quote approval, or explicit maintainer approval.
5. Create the fix against a clean checkout of upstream `openai/codex`.
6. Create `patches/<owner>/<repo>/issue-<number>/`.
7. Add a `README.md` describing the issue reference, scope of the fix, and any upstream links.
8. Generate one or more patch files with `git format-patch` and store them in that directory.
9. Name a single patch `<short-slug>.patch`; for dependent patch series, use numeric prefixes such as `0001-` and `0002-` when explicit ordering is helpful.
10. Add a regression test before implementing the fix and verify that it fails for the unfixed code.
11. Implement the fix and verify that the same test passes.
12. Match the surrounding upstream test style rather than introducing repository-specific test conventions.
13. Record the regression test and its before/after results in the issue `README.md`.
14. Update any issue labels such as `funded`, `quote-request`, `professional-services`, or `maintainer-approved` as needed.
15. Once an early-access build containing the fix is ready, create the Paddle checkout link or invoice and deliver immediate access to the buyer after payment.
16. Early-access builds may contain multiple unreleased fixes; do not promise buyers exclusive access to only one isolated patch unless you are prepared to ship separate builds.
17. Add each purchased fix to the public release flow for this repository no later than 30 days after first customer delivery of that fix.

## Test It

1. Run `scripts/apply-patches.sh <upstream-checkout>`.
2. Run the regression test against the unfixed upstream checkout and confirm it fails.
3. Apply the fix and run the same regression test again, confirming it passes.
4. Run `scripts/build-release.sh <upstream-checkout>`.
5. Run the GitHub Actions `ci.yml` workflow manually if you need an Actions-based confirmation.
6. Verify that release notes mention the upstream tag, upstream commit SHA, patch list, supported platforms, and checksums.
7. If upstream changed its CI or release pipeline, update the fallback commands and target matrix in this repository before publishing.

## Release Manually

1. Trigger `.github/workflows/upstream-release-check.yml` with `workflow_dispatch`.
2. Optionally provide an explicit upstream tag or patch release number through workflow inputs.
3. Review the created GitHub Release and uploaded artifacts before announcing availability.

## Remove A Patch After Upstream Fixes It

1. Confirm the fix is present in an upstream release or commit.
2. Remove the corresponding `patches/<owner>/<repo>/issue-<number>/` directory.
3. Re-run `ci.yml` to confirm remaining patches still apply cleanly.
4. Note the removal in the next release notes.

## Early Access, Refunds, And Quote Requests

- Do not collect payment until an early-access build containing the fix is complete and available for immediate delivery.
- If a completed early-access build must later be refunded, assume non-refundable payment-processing or merchant-of-record fees may still be lost.
- Assume chargebacks may deduct both the original transaction amount and any separate processor dispute fee unless the dispute is later won.
- Keep quote requests out of public issue discussion when sensitive scope or commercial details are involved.
- For paid professional work with custom terms, use a separate written agreement covering support, warranty, SLA, and liability terms.

This document is operational guidance, not legal advice. Review customer-facing terms and refund handling with a lawyer before relying on them.
