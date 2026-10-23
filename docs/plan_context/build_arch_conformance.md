# Conformance to the cross-platform project build convention

The fleet build convention (the `cross-platform-project-build-arch` skill, read 2026-10-23) applies when a project deliberately adopts it. ai_edu is a LuaJIT project with no compiled products of its own, so most of the native-output rules reduce to small gaps:

- Platform names. Use `PF` = `<OS>-<ARCH>` (`linux-amd64`, `linux-arm64`, `macos-arm64`, `mswin-amd64`, `mswin-arm64`) in project-controlled identifiers. Nix system names (`x86_64-linux`) stay as Nix spells them at the flake boundary.
- `./build`: missing. It should default to Nix and build the current platform's product (a `packages.<system>.default` the flake does not yet expose: the LuaJIT environment plus `src/`, `content/` and `web/`), optimized by default, with explicit debug/test modes, an explicit `--backend=direct` path and documented native equivalent.
- `--all-plats` / `--all-platforms` and `--all`: build every declared platform. The flake evaluates for aarch64-linux and aarch64-darwin but has only been built on x86_64-linux; declare the real matrix and report unavailable builders instead of presenting a partial matrix as complete. Windows is undeclared.
- `./run`: the convention's launcher. Today `./serve` plays that role; either rename with callers, tests and docs updated together, or add `./run` as the contract name and keep `./serve` only if a user needs it.
- PATH-facing layout: `bin/<command>` for portable scripts only. `serve` currently sits at the root; a portable script must have portable interpreter and dependencies (it wraps itself in `nix develop`, which is acceptable as an explicit-invocation Nix bootstrap, never at shell startup).
- Outputs: retained Nix output links go under `.nix-out/<PF>/<profile>`, ignored by Git; no generated products in Git.
- `./test` already runs the exact flake check (`checks.<system>.tests`) and never tests another PATH installation; keep that.
- Single implementation, so no CANONICAL_IMPL machinery is needed.

Proof before claiming conformance: follow the skill's `references/verification-and-migration.md`.
