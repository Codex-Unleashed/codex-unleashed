# Release Verification Tooling

Public releases contain only the runnable package archives and
`SHA256SUMS.release.txt`, which is sufficient for normal download verification.

The repository retains the manifest generator and verifier for maintainer use and
for private release audits; their output is not published as a release asset.

The manifest records:

- the patched release tag and build date
- the upstream repository, tag, and commit used as the source base
- the patch repository and SHA-256 of every applied patch file
- the workflow metadata used to build the release
- every staged release asset except the manifest file itself and the later-added attestation bundle, with relative path, size, and SHA-256
- the checksum file and attestation bundle names used for verification

Use `scripts/verify-release.sh` to verify a downloaded release directory against this manifest.
