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
build_target="${UPSTREAM_TARGET:-}"

is_current_upstream_layout() {
  [[ -f pnpm-lock.yaml && -f codex-rs/Cargo.toml ]]
}

infer_host_target() {
  case "$(uname -s):$(uname -m)" in
    Linux:x86_64)
      printf '%s\n' "x86_64-unknown-linux-gnu"
      ;;
    Linux:aarch64|Linux:arm64)
      printf '%s\n' "aarch64-unknown-linux-gnu"
      ;;
    Darwin:x86_64)
      printf '%s\n' "x86_64-apple-darwin"
      ;;
    Darwin:arm64|Darwin:aarch64)
      printf '%s\n' "aarch64-apple-darwin"
      ;;
    MINGW*:x86_64|MSYS*:x86_64|CYGWIN*:x86_64|Windows_NT:x86_64)
      printf '%s\n' "x86_64-pc-windows-msvc"
      ;;
    MINGW*:aarch64|MSYS*:aarch64|CYGWIN*:aarch64|Windows_NT:aarch64)
      printf '%s\n' "aarch64-pc-windows-msvc"
      ;;
    *)
      return 1
      ;;
  esac
}

infer_default_release_target() {
  case "$(uname -s)" in
    Linux)
      printf '%s\n' "x86_64-unknown-linux-musl"
      ;;
    Darwin)
      printf '%s\n' "$(uname -m)-apple-darwin"
      ;;
    MINGW*|MSYS*|CYGWIN*|Windows_NT)
      if [[ "$(uname -m)" == "aarch64" ]]; then
        printf '%s\n' "aarch64-pc-windows-msvc"
      else
        printf '%s\n' "x86_64-pc-windows-msvc"
      fi
      ;;
    *)
      return 1
      ;;
  esac
}

default_release_binaries() {
  local target="${1:-}"

  if [[ -n "${UPSTREAM_BINARIES:-}" ]]; then
    printf '%s\n' "${UPSTREAM_BINARIES}"
    return 0
  fi

  case "${target}" in
    *windows*)
      printf '%s\n' "codex codex-code-mode-host codex-responses-api-proxy"
      ;;
    *linux*)
      printf '%s\n' "codex codex-code-mode-host codex-responses-api-proxy bwrap"
      ;;
    *)
      printf '%s\n' "codex codex-code-mode-host codex-responses-api-proxy"
      ;;
  esac
}

configure_rusty_v8_overrides() {
  local target="${1:-}"
  local version=""
  local release_tag=""
  local base_url=""
  local binding_dir=""
  local archive_name=""
  local archive_path=""
  local binding_path=""
  local checksums_path=""

  if [[ -z "${target}" ]]; then
    echo "ERROR: configure_rusty_v8_overrides requires a target triple" >&2
    exit 1
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is required to configure rusty_v8 artifact overrides" >&2
    exit 1
  fi

  version="$(python3 .github/scripts/rusty_v8_bazel.py resolved-v8-crate-version)"
  release_tag="rusty-v8-v${version}"
  base_url="https://github.com/openai/codex/releases/download/${release_tag}"
  binding_dir="${TMPDIR:-/tmp}/rusty_v8/${target}"
  if [[ "${target}" == *windows* ]]; then
    archive_name="rusty_v8_release_${target}.lib.gz"
  else
    archive_name="librusty_v8_release_${target}.a.gz"
  fi
  archive_path="${binding_dir}/${archive_name}"
  binding_path="${binding_dir}/src_binding_release_${target}.rs"
  checksums_path="${binding_dir}/rusty_v8_release_${target}.sha256"

  mkdir -p "${binding_dir}"
  curl -fsSL "${base_url}/${archive_name}" -o "${archive_path}"
  curl -fsSL "${base_url}/src_binding_release_${target}.rs" -o "${binding_path}"
  curl -fsSL "${base_url}/rusty_v8_release_${target}.sha256" -o "${checksums_path}"

  if [[ "$(wc -l < "${checksums_path}")" -ne 2 ]]; then
    echo "ERROR: expected exactly two checksums for ${target} in ${checksums_path}" >&2
    exit 1
  fi

  if command -v sha256sum >/dev/null 2>&1; then
    (cd "${binding_dir}" && sha256sum -c "${checksums_path}")
  else
    (cd "${binding_dir}" && shasum -a 256 -c "${checksums_path}")
  fi

  export RUSTY_V8_ARCHIVE="${archive_path}"
  export RUSTY_V8_SRC_BINDING_PATH="${binding_path}"
}

should_configure_rusty_v8_overrides() {
  local target="${1:-}"
  [[ -n "${target}" && "${target}" != *windows* ]]
}

run_with_heartbeat() {
  local heartbeat_pid=""

  (
    while true; do
      sleep "${HEARTBEAT_INTERVAL_SECONDS:-60}"
      printf 'Heartbeat: command still running at %s\n' "$(date -u +%FT%TZ)"
    done
  ) &
  heartbeat_pid=$!

  set +e
  "$@"
  local command_status=$?
  set -e

  kill "${heartbeat_pid}" >/dev/null 2>&1 || true
  wait "${heartbeat_pid}" 2>/dev/null || true

  return "${command_status}"
}

if [[ ! -d "${target_dir}/.git" ]]; then
  echo "ERROR: target is not a git checkout: ${target_dir}" >&2
  exit 1
fi

"${repo_root}/scripts/apply-patches.sh" "${target_dir}"

pushd "${target_dir}" >/dev/null

if [[ "${SKIP_UPSTREAM_TESTS:-0}" == "1" ]]; then
  echo "Skipping upstream tests because SKIP_UPSTREAM_TESTS=1"
elif [[ -n "${UPSTREAM_TEST_COMMAND:-}" ]]; then
  echo "Running UPSTREAM_TEST_COMMAND"
  if is_current_upstream_layout; then
    test_target="${UPSTREAM_TEST_TARGET:-${build_target:-}}"
    if [[ -z "${test_target}" ]]; then
      test_target="$(infer_host_target)"
    fi
    if should_configure_rusty_v8_overrides "${test_target}"; then
      configure_rusty_v8_overrides "${test_target}"
    fi
  fi
  bash -lc "${UPSTREAM_TEST_COMMAND}"
elif is_current_upstream_layout; then
  echo "Detected current upstream Codex layout; running default upstream-aligned checks."
  if ! command -v pnpm >/dev/null 2>&1; then
    echo "ERROR: pnpm is required for the current upstream Codex default test path" >&2
    exit 1
  fi
  if ! command -v cargo >/dev/null 2>&1; then
    echo "ERROR: cargo is required for the current upstream Codex default test path" >&2
    exit 1
  fi
  if ! command -v just >/dev/null 2>&1; then
    echo "ERROR: just is required for the current upstream Codex default test path" >&2
    exit 1
  fi
  test_target="${UPSTREAM_TEST_TARGET:-${build_target:-}}"
  if [[ -z "${test_target}" ]]; then
    test_target="$(infer_host_target)"
  fi
  if should_configure_rusty_v8_overrides "${test_target}"; then
    configure_rusty_v8_overrides "${test_target}"
  fi
  pnpm install --frozen-lockfile
  python3 .github/scripts/verify_cargo_workspace_manifests.py
  python3 .github/scripts/verify_tui_core_boundary.py
  python3 .github/scripts/verify_bazel_clippy_lints.py
  python3 -m unittest discover -s scripts/codex_package -p 'test_*.py'
  if [[ -d scripts/install ]]; then
    python3 -m unittest discover -s scripts/install -p 'test_*.py'
  fi
  just fmt-check
  pnpm run format
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

if [[ "${SKIP_UPSTREAM_BUILD:-0}" == "1" ]]; then
  echo "Skipping upstream build because SKIP_UPSTREAM_BUILD=1"
elif [[ -n "${UPSTREAM_BUILD_COMMAND:-}" ]]; then
  echo "Running UPSTREAM_BUILD_COMMAND"
  bash -lc "${UPSTREAM_BUILD_COMMAND}"
elif is_current_upstream_layout; then
  echo "Detected current upstream Codex layout; running default upstream-aligned build."
  if [[ -z "${build_target}" ]]; then
    build_target="$(infer_default_release_target)" || {
      echo "ERROR: unable to infer default UPSTREAM_TARGET for $(uname -s)" >&2
      exit 1
    }
  fi

  if ! command -v rustup >/dev/null 2>&1; then
    echo "ERROR: rustup is required for target-aware current upstream Codex builds" >&2
    exit 1
  fi
  rustup target add "${build_target}"
  if should_configure_rusty_v8_overrides "${build_target}"; then
    configure_rusty_v8_overrides "${build_target}"
  fi

  release_binaries="$(default_release_binaries "${build_target}")"
  build_args=(--manifest-path ./codex-rs/Cargo.toml --release --target "${build_target}")
  for binary in ${release_binaries}; do
    build_args+=(--bin "${binary}")
  done

  if [[ "${build_target}" == "x86_64-pc-windows-msvc" ]]; then
    export LIBSQLITE3_FLAGS=SQLITE_DISABLE_INTRINSIC
  fi

  run_with_heartbeat cargo build "${build_args[@]}"
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
elif is_current_upstream_layout; then
  echo "Detected current upstream Codex layout; collecting default release binaries."
  artifact_target="${build_target}"
  if [[ -z "${artifact_target}" ]]; then
    echo "ERROR: artifact collection requires UPSTREAM_TARGET or an inferred build target" >&2
    exit 1
  fi

  release_binaries="$(default_release_binaries "${artifact_target}")"
  release_dir="codex-rs/target/${artifact_target}/release"
  for binary in ${release_binaries}; do
    if [[ -f "${release_dir}/${binary}" ]]; then
      cp -f "${release_dir}/${binary}" "${output_dir}/"
    elif [[ -f "${release_dir}/${binary}.exe" ]]; then
      cp -f "${release_dir}/${binary}.exe" "${output_dir}/"
    else
      echo "ERROR: expected artifact not found for ${binary} under ${release_dir}" >&2
      exit 1
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
