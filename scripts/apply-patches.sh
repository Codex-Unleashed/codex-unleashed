#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: apply-patches.sh <upstream-checkout>

Applies every patch under patches/*.patch to the target checkout.
Fails immediately if any patch does not apply.
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

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_dir="$(cd "${1}" && pwd)"
patch_dir="${repo_root}/patches"

if [[ ! -d "${target_dir}/.git" ]]; then
  echo "ERROR: target is not a git checkout: ${target_dir}" >&2
  exit 1
fi

cleanup_on_error() {
  git -C "${target_dir}" am --abort >/dev/null 2>&1 || true
}

trap cleanup_on_error ERR

shopt -s nullglob
patches=("${patch_dir}"/*.patch)
shopt -u nullglob

if [[ ${#patches[@]} -eq 0 ]]; then
  echo "No patch files found in ${patch_dir}; nothing to apply."
  exit 0
fi

for patch_file in "${patches[@]}"; do
  echo "Applying $(basename "${patch_file}")"
  git -C "${target_dir}" am --3way --keep-cr "${patch_file}"
done

trap - ERR
