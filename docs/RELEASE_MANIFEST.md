# Release Manifest

Each published patched release includes a machine-readable `release-manifest.json`.

The manifest records:

- the patched release tag and build date
- the upstream repository, tag, and commit used as the source base
- the patch repository and SHA-256 of every applied patch file
- the workflow metadata used to build the release
- every staged release asset except the manifest file itself and the later-added attestation bundle, with relative path, size, and SHA-256
- the checksum file and attestation bundle names used for verification

Use `scripts/verify-release.sh` to verify a downloaded release directory against this manifest.
