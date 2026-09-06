import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).with_name("generate-source-provenance.py")


class SourceAuditTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.checkout = self.root / "upstream"
        self.checkout.mkdir()
        self.repo = self.root / "patch-repo"
        (self.repo / "patches").mkdir(parents=True)
        self.git("init", "-q")
        self.git("config", "user.name", "Test")
        self.git("config", "user.email", "test@example.invalid")
        (self.checkout / "source.txt").write_text("baseline\n")
        self.git("add", ".")
        self.git("commit", "-qm", "baseline")

    def git(self, *args):
        return subprocess.check_output(
            ["git", "-C", str(self.checkout), *args], text=True
        )

    def audit(self):
        return subprocess.run([
            sys.executable, str(SCRIPT), "--upstream-checkout", str(self.checkout),
            "--patch-repo", str(self.repo), "--output", str(self.root / "audit.json"),
        ], capture_output=True, text=True)

    def test_no_patches_preserves_upstream_tree(self):
        result = self.audit()
        self.assertEqual(result.returncode, 0, result.stderr)
        manifest = json.loads((self.root / "audit.json").read_text())
        self.assertEqual(manifest["patched_tree"], manifest["upstream"]["baseline_tree"])

    def test_rejects_unexplained_tracked_edit(self):
        (self.checkout / "source.txt").write_text("injected\n")
        self.assertNotEqual(self.audit().returncode, 0)

    def test_rejects_unexplained_new_source(self):
        (self.checkout / "injected.rs").write_text("fn injected() {}\n")
        self.assertNotEqual(self.audit().returncode, 0)

    def test_patch_additions_and_deletions_are_verified(self):
        (self.checkout / "source.txt").unlink()
        (self.checkout / "new source.txt").write_text("patched\n")
        self.git("add", "-A")
        patch = self.git("diff", "--cached", "--binary")
        (self.repo / "patches" / "fix.patch").write_text(patch)
        result = self.audit()
        self.assertEqual(result.returncode, 0, result.stderr)
        manifest = json.loads((self.root / "audit.json").read_text())
        self.assertEqual(manifest["changed_paths"], ["new source.txt", "source.txt"])

    def test_rejects_listed_but_unapplied_patch(self):
        (self.checkout / "source.txt").write_text("patched\n")
        (self.repo / "patches" / "fix.patch").write_text(self.git("diff"))
        (self.checkout / "source.txt").write_text("baseline\n")
        self.assertNotEqual(self.audit().returncode, 0)


if __name__ == "__main__":
    unittest.main()
