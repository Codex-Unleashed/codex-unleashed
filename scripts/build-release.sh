#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: build-release.sh <upstream-checkout> [output-dir]

Applies repository patches, runs upstream checks, and builds release artifacts.
This script intentionally contains TODO markers where upstream-specific build
details must be confirmed by the maintainer.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage >&2
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_dir="$(cd "${1}" && pwd)"
output_dir="${2:-${repo_root}/dist}"
output_dir="$(mkdir -p "${output_dir}" && cd "${output_dir}" && pwd)"

if [[ ! -d "${target_dir}/.git" ]]; then
  echo "ERROR: target is not a git checkout: ${target_dir}" >&2
  exit 1
fi

"${repo_root}/scripts/apply-patches.sh" "${target_dir}"

pushd "${target_dir}" >/dev/null

if [[ -n "${UPSTREAM_TEST_COMMAND:-}" ]]; then
  echo "Running UPSTREAM_TEST_COMMAND"
  bash -lc "${UPSTREAM_TEST_COMMAND}"
elif [[ -f pnpm-lock.yaml && -f codex-rs/Cargo.toml ]]; then
  echo "Detected current upstream Codex layout; running conservative default checks."
  if ! command -v pnpm >/dev/null 2>&1; then
    echo "ERROR: pnpm is required for the current upstream Codex default test path" >&2
    exit 1
  fi
  if ! command -v cargo >/dev/null 2>&1; then
    echo "ERROR: cargo is required for the current upstream Codex default test path" >&2
    exit 1
  fi
  pnpm install --frozen-lockfile
  pnpm run format
  cargo fmt --manifest-path ./codex-rs/Cargo.toml -- --config imports_granularity=Item --check
  cargo test --manifest-path ./codex-rs/Cargo.toml
elif [[ -f pnpm-lock.yaml ]]; then
  echo "Detected pnpm-lock.yaml; running conservative pnpm checks."
  if command -v pnpm >/dev/null 2>&1; then
    pnpm install --frozen-lockfile
    pnpm test
  else
    echo "ERROR: pnpm is required to build pnpm-based upstream projects" >&2
    exit 1
  fi
elif [[ -f package.json ]]; then
  echo "Detected package.json; running conservative Node checks."
  if command -v npm >/dev/null 2>&1; then
    npm ci
    npm test
  else
    echo "ERROR: npm is required to build package.json-based upstream projects" >&2
    exit 1
  fi
elif [[ -f Cargo.toml ]]; then
  echo "Detected Cargo.toml; running conservative Rust checks."
  if command -v cargo >/dev/null 2>&1; then
    cargo test --locked
  else
    echo "ERROR: cargo is required to build Rust-based upstream projects" >&2
    exit 1
  fi
else
  echo "TODO: verify upstream Codex build and test commands for this checkout." >&2
  echo "Set UPSTREAM_TEST_COMMAND explicitly or extend scripts/build-release.sh." >&2
  exit 1
fi

if [[ -n "${UPSTREAM_BUILD_COMMAND:-}" ]]; then
  echo "Running UPSTREAM_BUILD_COMMAND"
  bash -lc "${UPSTREAM_BUILD_COMMAND}"
elif [[ -f pnpm-lock.yaml && -f codex-rs/Cargo.toml ]]; then
  echo "Detected current upstream Codex layout; running conservative default build."
  cargo build --manifest-path ./codex-rs/Cargo.toml --release --bin codex
else
  echo "TODO: set UPSTREAM_BUILD_COMMAND to the exact upstream release build command." >&2
  exit 1
fi

if [[ -n "${UPSTREAM_ARTIFACT_GLOB:-}" ]]; then
  echo "Collecting artifacts from ${UPSTREAM_ARTIFACT_GLOB}"
  shopt -s nullglob
  artifacts=(${UPSTREAM_ARTIFACT_GLOB})
  shopt -u nullglob
  if [[ ${#artifacts[@]} -eq 0 ]]; then
    echo "ERROR: no artifacts matched UPSTREAM_ARTIFACT_GLOB=${UPSTREAM_ARTIFACT_GLOB}" >&2
    exit 1
  fi
  for artifact in "${artifacts[@]}"; do
    cp -f "${artifact}" "${output_dir}/"
  done
elif [[ "${SKIP_ARTIFACT_COLLECTION:-0}" == "1" ]]; then
  echo "Skipping artifact collection because SKIP_ARTIFACT_COLLECTION=1"
  popd >/dev/null
  echo "Artifacts were intentionally skipped."
  exit 0
elif [[ -f pnpm-lock.yaml && -f codex-rs/Cargo.toml ]]; then
  echo "Detected current upstream Codex layout; collecting conservative default artifacts."
  shopt -s nullglob
  artifacts=(codex-rs/target/release/codex*)
  shopt -u nullglob
  if [[ ${#artifacts[@]} -eq 0 ]]; then
    echo "ERROR: no default artifacts found under codex-rs/target/release/" >&2
    exit 1
  fi
  for artifact in "${artifacts[@]}"; do
    if [[ -f "${artifact}" ]]; then
      cp -f "${artifact}" "${output_dir}/"
    fi
  done
else
  echo "TODO: set UPSTREAM_ARTIFACT_GLOB so release artifacts can be collected." >&2
  exit 1
fi

popd >/dev/null

if command -v sha256sum >/dev/null 2>&1; then
  (cd "${output_dir}" && sha256sum ./* > SHA256SUMS)
elif command -v shasum >/dev/null 2>&1; then
  (cd "${output_dir}" && shasum -a 256 ./* > SHA256SUMS)
else
  echo "ERROR: need sha256sum or shasum to generate checksums" >&2
  exit 1
fi

echo "Artifacts written to ${output_dir}"
