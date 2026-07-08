#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: sync-upstream-github.sh [upstream-ref]

Refresh the vendored snapshot of upstream OpenAI Codex GitHub workflows,
actions, and helper scripts.

Examples:
  sync-upstream-github.sh
  sync-upstream-github.sh main
  sync-upstream-github.sh rust-v0.143.0
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

upstream_ref="${1:-main}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

git clone --depth 1 --branch "${upstream_ref}" https://github.com/openai/codex.git "${tmp_dir}/upstream"

vendor_root="vendor/openai-codex/.github"
mkdir -p "${vendor_root}"
rm -rf "${vendor_root}/workflows" "${vendor_root}/actions" "${vendor_root}/scripts"
cp -R "${tmp_dir}/upstream/.github/workflows" "${vendor_root}/"
cp -R "${tmp_dir}/upstream/.github/actions" "${vendor_root}/"
cp -R "${tmp_dir}/upstream/.github/scripts" "${vendor_root}/"

echo "Synced upstream GitHub metadata from openai/codex@${upstream_ref}"
