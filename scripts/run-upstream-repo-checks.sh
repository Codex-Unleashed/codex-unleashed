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
export CODEX_REPO_ROOT="${target_dir}"
if [[ "${ALLOW_STALE_CODE_MODE_FEATURE_EXCEPTION:-0}" == "1" ]]; then
  # The upstream tag can contain the historical exception even after the
  # corresponding feature has disappeared. Filter only that one diagnostic;
  # the exception remains active, so it is still validated if the feature
  # returns. All other manifest checks remain enabled and still fail normally.
  python3 - <<'PY'
import runpy

verifier = runpy.run_path(".github/scripts/verify_cargo_workspace_manifests.py")
add_unused_exception_errors = verifier["add_unused_exception_errors"]


def add_unused_exception_errors_without_stale_code_mode(
    failures_by_path,
    used_manifest_feature_exceptions,
    used_optional_dependency_exceptions,
    used_internal_dependency_feature_exceptions,
):
    add_unused_exception_errors(
        failures_by_path,
        used_manifest_feature_exceptions,
        used_optional_dependency_exceptions,
        used_internal_dependency_feature_exceptions,
    )
    path = "codex-rs/code-mode/Cargo.toml"
    error = (
        "remove the stale `[features]` exception from "
        "`MANIFEST_FEATURE_EXCEPTIONS`"
    )
    errors = failures_by_path.get(path)
    if errors is None:
        return
    errors[:] = [candidate for candidate in errors if candidate != error]
    if not errors:
        del failures_by_path[path]


verifier["main"].__globals__["add_unused_exception_errors"] = (
    add_unused_exception_errors_without_stale_code_mode
)
raise SystemExit(verifier["main"]())
PY
else
  python3 .github/scripts/verify_cargo_workspace_manifests.py
fi
python3 .github/scripts/verify_tui_core_boundary.py
python3 .github/scripts/verify_bazel_clippy_lints.py
python3 -m unittest discover -s scripts/codex_package -p 'test_*.py'
if [[ -d scripts/install ]]; then
  python3 -m unittest discover -s scripts/install -p 'test_*.py'
fi
just fmt-check
pnpm run format
popd >/dev/null
