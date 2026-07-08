#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: run-upstream-repo-checks.sh <upstream-checkout>

Run the upstream Codex repository checks against a patched upstream checkout.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 1
fi

target_dir="$(cd "${1}" && pwd)"

if [[ ! -d "${target_dir}/.git" ]]; then
  echo "ERROR: target is not a git checkout: ${target_dir}" >&2
  exit 1
fi

pushd "${target_dir}" >/dev/null
python3 .github/scripts/verify_cargo_workspace_manifests.py
python3 .github/scripts/verify_tui_core_boundary.py
python3 .github/scripts/verify_bazel_clippy_lints.py
python3 -m unittest discover -s scripts/codex_package -p 'test_*.py'
if [[ -d scripts/install ]]; then
  python3 -m unittest discover -s scripts/install -p 'test_*.py'
fi
just fmt-check
pnpm run format
popd >/dev/null
