# .github

Everything shared between my repositories lives here, in three layers.

## 1. Inherited automatically

`SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `.github/ISSUE_TEMPLATE/`,
`.github/PULL_REQUEST_TEMPLATE.md`.

GitHub does not copy these anywhere. If a repository has no file of its own, GitHub shows
the one from here; if it has its own, that one wins (for that repository only).
Exception: issue templates are all-or-nothing — one local template disables all defaults.

## 2. Shared CI logic (called, not copied)

Reusable workflows in `.github/workflows/`, used as
`casablanque-code/.github/.github/workflows/<name>.yml@v1`:

| Workflow | Purpose |
| --- | --- |
| `go-ci` / `rust-ci` / `node-ci` | lint, test (coverage), build, `ci-ok` gate job |
| `gitleaks` | secret scan over the full history |
| `release` | validates the `vX.Y.Z` tag, creates a GitHub Release |
| `rust-release` | 5-target binaries + sha256, tag must equal `Cargo.toml` version |
| `go-release` | GoReleaser |

Change one of them here, tag a release, every project gets it:

```bash
git tag v1.1.0 && git push origin v1.1.0   # `tag-major` moves v1 to this commit
```

## 3. Copied once, when a project is created

`templates/` holds starter files per language. Create a repo with:

```bash
scripts/new-repo.sh <rust|go|node-ts> <name> "<description>"
```

It renders the template (name and description are filled in everywhere), creates the GitHub
repo, pushes `main` and applies the repo settings from `scripts/setup-repo.sh`.
After that the project owns its copy — change it freely.

Settings can be re-applied to any existing repository:
`scripts/setup-repo.sh owner/repo`.

## Optional

`optional/dependabot-auto-merge.yml` — auto-merge for Dependabot patch/minor PRs.
Copy it to `.github/workflows/` of a project if you want it.

## Releasing a project

Releases are cut from `main` by pushing a `vX.Y.Z` tag (`vX.Y.Z-rc.1` makes a prerelease).

```bash
# Go
git tag v0.2.0 && git push origin v0.2.0
# Rust: bump `version` in Cargo.toml and commit first — the tag must equal it
git tag v0.2.0 && git push origin main v0.2.0
# Node
npm version minor && git push origin main --follow-tags
```

Rust/Go projects get binaries for linux/macos/windows with checksums attached; publishing to
crates.io / npm is prepared (commented out, trusted publishing) in each `release.yml`.
