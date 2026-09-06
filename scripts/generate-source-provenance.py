#!/usr/bin/env python3
"""Record the exact upstream tree and patch result used for a build."""

import argparse
import hashlib
import json
import os
import subprocess
from pathlib import Path


def run_git(checkout: Path, *args: str, index: Path | None = None) -> str:
    env = os.environ.copy()
    if index is not None:
        env["GIT_INDEX_FILE"] = str(index)
    return subprocess.check_output(
        ["git", "-C", str(checkout), *args],
        env=env,
        text=True,
    ).strip()


def sha256_git_diff(checkout: Path, index: Path) -> str:
    process = subprocess.Popen(
        ["git", "-C", str(checkout), "diff", "--cached", "--binary", "--no-ext-diff"],
        env={**os.environ, "GIT_INDEX_FILE": str(index)},
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    assert process.stdout is not None
    digest = hashlib.sha256()
    for chunk in iter(lambda: process.stdout.read(1024 * 1024), b""):
        digest.update(chunk)
    stderr = process.stderr.read().decode()
    if process.wait() != 0:
        raise RuntimeError(stderr)
    return digest.hexdigest()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--upstream-checkout", required=True, type=Path)
    parser.add_argument("--patch-repo", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--upstream-repository", default="openai/codex")
    parser.add_argument("--upstream-ref", default="")
    parser.add_argument("--workflow-path", default="")
    parser.add_argument("--workflow-sha", default="")
    parser.add_argument("--workflow-run-id", default="")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    checkout = args.upstream_checkout.resolve()
    patch_repo = args.patch_repo.resolve()
    output = args.output.resolve()
    original_commit = run_git(checkout, "rev-parse", "HEAD")

    patch_files = sorted(patch_repo.glob("patches/**/*.patch"))
    patches = []
    for path in patch_files:
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        patches.append({"path": path.relative_to(patch_repo).as_posix(), "sha256": digest})

    index = output.with_suffix(".index")
    try:
        run_git(checkout, "read-tree", "HEAD", index=index)
        run_git(checkout, "add", "--all", index=index)
        patched_tree = run_git(checkout, "write-tree", index=index)
        changed_paths = run_git(checkout, "diff", "--cached", "--name-only", index=index)
        changed_paths = [line for line in changed_paths.splitlines() if line]
        diff_sha256 = sha256_git_diff(checkout, index)
        subprocess.run(
            ["git", "-C", str(checkout), "diff", "--cached", "--check"],
            env={**os.environ, "GIT_INDEX_FILE": str(index)},
            check=True,
        )
    finally:
        index.unlink(missing_ok=True)

    manifest = {
        "schema_version": 1,
        "upstream": {
            "repository": args.upstream_repository,
            "ref": args.upstream_ref,
            "commit": original_commit,
            "baseline_tree": run_git(checkout, "rev-parse", "HEAD^{tree}"),
        },
        "patches": patches,
        "application_order": [patch["path"] for patch in patches],
        "patched_tree": patched_tree,
        "applied_diff_sha256": diff_sha256,
        "changed_paths": changed_paths,
        "workflow": {
            "path": args.workflow_path,
            "sha": args.workflow_sha,
            "run_id": args.workflow_run_id,
        },
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="ascii")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
