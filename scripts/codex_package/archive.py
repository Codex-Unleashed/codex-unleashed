"""Archive writers for canonical Codex package directories."""

import gzip
import json
import os
import shutil
import subprocess
import tarfile
import tempfile
import zipfile
from collections.abc import Callable
from pathlib import Path

from .targets import PATCH_REPO_ROOT


ZSTD_DOTSLASH = PATCH_REPO_ROOT / ".github" / "workflows" / "zstd"


def write_archive(package_dir: Path, archive_path: Path, *, force: bool) -> None:
    if is_relative_to(archive_path, package_dir):
        raise RuntimeError(
            f"Archive output must be outside the package directory: {archive_path}"
        )

    archive_path.parent.mkdir(parents=True, exist_ok=True)
    if archive_path.exists():
        if not force:
            raise RuntimeError(f"Archive output already exists: {archive_path}")
        archive_path.unlink()

    archive_format = archive_format_for_path(archive_path)
    if archive_format == "tar.gz":
        write_tar_archive(package_dir, archive_path, mode="w:gz")
    elif archive_format == "tar.zst":
        write_tar_zst_archive(package_dir, archive_path)
    elif archive_format == "zip":
        write_zip_archive(package_dir, archive_path)
    else:
        raise AssertionError(f"unexpected archive format: {archive_format}")


def is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def archive_format_for_path(path: Path) -> str:
    suffixes = path.suffixes
    if suffixes[-2:] == [".tar", ".gz"] or path.suffix == ".tgz":
        return "tar.gz"
    if suffixes[-2:] == [".tar", ".zst"]:
        return "tar.zst"
    if path.suffix == ".zip":
        return "zip"
    raise RuntimeError(
        f"Unsupported archive suffix for {path}. Use .tar.gz, .tgz, .tar.zst, or .zip."
    )


def write_tar_archive(package_dir: Path, archive_path: Path, *, mode: str) -> None:
    if mode == "w:gz":
        gzip_file = gzip.GzipFile(
            filename=str(archive_path),
            mode="wb",
            mtime=archive_gzip_mtime(),
        )
        archive = tarfile.open(fileobj=gzip_file, mode="w")
    else:
        gzip_file = None
        archive = tarfile.open(archive_path, mode)

    try:
        for path in package_entries(package_dir):
            archive.add(
                path,
                arcname=path.relative_to(package_dir),
                recursive=False,
                filter=normalize_tar_info,
            )
    finally:
        archive.close()
        if gzip_file is not None:
            gzip_file.close()


def archive_mtime() -> int | None:
    value = os.environ.get("CODEX_PACKAGE_ARCHIVE_MTIME")
    if value is None:
        value = os.environ.get("SOURCE_DATE_EPOCH")
    if value is None:
        return None
    try:
        return int(value)
    except ValueError as exc:
        raise RuntimeError("SOURCE_DATE_EPOCH must be an integer") from exc


def archive_gzip_mtime() -> int | None:
    value = os.environ.get("CODEX_PACKAGE_ARCHIVE_GZIP_MTIME")
    if value is None:
        return None
    try:
        return int(value)
    except ValueError as exc:
        raise RuntimeError(
            "CODEX_PACKAGE_ARCHIVE_GZIP_MTIME must be an integer"
        ) from exc


def normalize_tar_info(info: tarfile.TarInfo) -> tarfile.TarInfo:
    member_mtimes = archive_member_mtimes()
    if info.name in member_mtimes:
        info.mtime = member_mtimes[info.name]
        return info

    mtime = archive_mtime()
    if mtime is not None:
        info.mtime = mtime
    return info


def archive_member_mtimes() -> dict[str, float]:
    value = os.environ.get("CODEX_PACKAGE_ARCHIVE_MEMBER_MTIMES")
    if value is None:
        return {}
    try:
        parsed = json.loads(value)
    except json.JSONDecodeError as exc:
        raise RuntimeError(
            "CODEX_PACKAGE_ARCHIVE_MEMBER_MTIMES must be a JSON object"
        ) from exc
    if not isinstance(parsed, dict):
        raise RuntimeError(
            "CODEX_PACKAGE_ARCHIVE_MEMBER_MTIMES must be a JSON object"
        )
    try:
        return {str(name): float(mtime) for name, mtime in parsed.items()}
    except (TypeError, ValueError) as exc:
        raise RuntimeError(
            "CODEX_PACKAGE_ARCHIVE_MEMBER_MTIMES values must be numbers"
        ) from exc


def write_tar_zst_archive(package_dir: Path, archive_path: Path) -> None:
    zstd_command = resolve_zstd_command()

    with tempfile.TemporaryDirectory(prefix="codex-package-archive-") as temp_dir_str:
        tar_path = Path(temp_dir_str) / "package.tar"
        write_tar_archive(package_dir, tar_path, mode="w")
        subprocess.check_call(
            [*zstd_command, "-T0", "-19", "-f", str(tar_path), "-o", str(archive_path)]
        )


def resolve_zstd_command(
    *,
    dotslash_manifest: Path = ZSTD_DOTSLASH,
    which: Callable[[str], str | None] = shutil.which,
) -> list[str]:
    zstd = which("zstd")
    if zstd is not None:
        return [zstd]

    dotslash = which("dotslash")
    if dotslash is not None and dotslash_manifest.is_file():
        return [dotslash, str(dotslash_manifest)]

    raise RuntimeError(
        "zstd is required to write .tar.zst archives. Install zstd, or install "
        f"DotSlash so the repository wrapper can run: {dotslash_manifest}"
    )


def write_zip_archive(package_dir: Path, archive_path: Path) -> None:
    with zipfile.ZipFile(
        archive_path, "w", compression=zipfile.ZIP_DEFLATED
    ) as archive:
        for path in package_entries(package_dir):
            relative_path = path.relative_to(package_dir)
            if path.is_dir():
                archive.write(path, f"{relative_path}/")
            else:
                archive.write(path, relative_path)


def package_entries(package_dir: Path) -> list[Path]:
    return sorted(
        package_dir.rglob("*"),
        key=lambda path: path.relative_to(package_dir).as_posix(),
    )
