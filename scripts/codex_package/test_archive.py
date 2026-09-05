#!/usr/bin/env python3

from pathlib import Path
import os
import sys
import tarfile
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from codex_package.archive import write_tar_archive
from codex_package.archive import resolve_zstd_command


class ResolveZstdCommandTest(unittest.TestCase):
    def test_prefers_zstd_from_path(self) -> None:
        def which(name: str) -> str | None:
            return {"zstd": "/usr/bin/zstd", "dotslash": "/usr/bin/dotslash"}.get(name)

        self.assertEqual(resolve_zstd_command(which=which), ["/usr/bin/zstd"])

    def test_falls_back_to_dotslash_manifest(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            manifest = Path(temp_dir) / "zstd"
            manifest.write_text("#!/usr/bin/env dotslash\n{}\n", encoding="utf-8")

            def which(name: str) -> str | None:
                return {"dotslash": "/usr/bin/dotslash"}.get(name)

            self.assertEqual(
                resolve_zstd_command(dotslash_manifest=manifest, which=which),
                ["/usr/bin/dotslash", str(manifest)],
            )

    def test_errors_when_no_zstd_or_dotslash_manifest_is_available(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            missing_manifest = Path(temp_dir) / "zstd"

            with self.assertRaisesRegex(RuntimeError, "zstd is required"):
                resolve_zstd_command(
                    dotslash_manifest=missing_manifest,
                    which=lambda _name: None,
                )

    def test_tar_archive_uses_source_date_epoch_for_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            package_dir = root / "package"
            package_dir.mkdir()
            (package_dir / "file").write_text("content", encoding="utf-8")
            archive_path = root / "package.tar.gz"

            with patch.dict(
                os.environ,
                {
                    "SOURCE_DATE_EPOCH": "1234567890",
                    "CODEX_PACKAGE_ARCHIVE_GZIP_MTIME": "1234567891",
                },
            ):
                write_tar_archive(package_dir, archive_path, mode="w:gz")

            with tarfile.open(archive_path, "r:gz") as archive:
                member = archive.getmember("file")
                self.assertEqual(member.mtime, 1234567890)

            self.assertEqual(
                archive_path.read_bytes()[4:8],
                (1234567891).to_bytes(4, "little"),
            )

    def test_tar_archive_preserves_reference_member_mtimes(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            package_dir = root / "package"
            package_dir.mkdir()
            (package_dir / "file").write_text("content", encoding="utf-8")
            archive_path = root / "package.tar.gz"

            with patch.dict(
                os.environ,
                {
                    "CODEX_PACKAGE_ARCHIVE_MEMBER_MTIMES": '{"file": 1234567890.125}',
                    "SOURCE_DATE_EPOCH": "1",
                },
            ):
                write_tar_archive(package_dir, archive_path, mode="w:gz")

            with tarfile.open(archive_path, "r:gz") as archive:
                self.assertEqual(
                    archive.getmember("file").mtime,
                    1234567890.125,
                )


if __name__ == "__main__":
    unittest.main()
