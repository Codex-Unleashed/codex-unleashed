#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: check-upstream-release.sh [owner/repo]

Prints a JSON object describing the latest upstream release.
Prefers the GitHub CLI (`gh`) and falls back to `curl`.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo="${1:-openai/codex}"
api_path="repos/${repo}/releases/latest"

if command -v gh >/dev/null 2>&1; then
  gh api "${api_path}"
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: neither gh nor curl is available" >&2
  exit 1
fi

url="https://api.github.com/${api_path}"
headers=(
  -H "Accept: application/vnd.github+json"
)

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  headers+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

curl --fail --silent --show-error "${headers[@]}" "${url}"
