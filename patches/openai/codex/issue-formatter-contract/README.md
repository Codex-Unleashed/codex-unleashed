# Keep formatter contract tests aligned

The upstream formatter driver now invokes `cargo fmt` for Rust files, while
the upstream contract test still expects the former direct `rustfmt` command.
This maintenance patch keeps the test aligned with the driver so repository
and SDK checks continue to validate the current behavior.

The patch is a CI compatibility fix and is removed when the equivalent change
lands upstream.
