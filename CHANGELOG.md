# Changelog

All notable changes to this template are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to the versioning policy documented in the
[README](README.md#versioning--releases).

Because the pinned dependency stack (R, Quarto, `{renv}`) *is* the product here,
every release note calls out the versions it ships.

## [Unreleased]

Dependency stack: **R 4.5.2**, **Quarto 1.9.38**, **`{renv}` 1.2.3**

### Added

- Reusable `dev` base image, defined in `Dockerfile.base` and published to
  `ghcr.io/ketchbrookanalytics/quarto-pdf-dev` by
  [.github/workflows/publish-image.yml](.github/workflows/publish-image.yml).
  New projects pull the pre-built base instead of rebuilding R and Quarto from
  scratch. Rebuilt weekly so OS/security patches stay current.
- Semver release tagging. Publishing a `vX.Y.Z` GitHub Release now stamps the
  base image with immutable `X.Y.Z` / `vX.Y.Z` tags plus a floating `X.Y` minor
  line, so a handoff can pin a known-good dependency stack by version instead of
  by commit SHA.
- A smoke test ([.github/scripts/smoke-test.sh](.github/scripts/smoke-test.sh))
  that renders [report.qmd](report.qmd) inside every published base image, so a
  build that assembles but can't actually render fails in CI rather than in
  someone's devcontainer. The render covers `{pak}`, the knitr engine, Quarto's
  Typst backend, Chrome Headless Shell (the mermaid diagrams), and the Roboto and
  emoji fonts. Every run tests `linux/amd64`; scheduled and release runs also
  test `linux/arm64` through QEMU, so the architecture that reaches Apple Silicon
  devcontainers is exercised before anyone pins it.
- Multi-architecture base image (`linux/amd64` and `linux/arm64`), built with
  QEMU + Buildx.
- Chrome Headless Shell, installed via `quarto install`, so mermaid and graphviz
  diagrams render without a system Chrome/Chromium package.
- Emoji support in rendered PDFs, via `fonts-noto-color-emoji`.
- Devcontainer tooling: the [arf](https://github.com/eitsupi/arf) R terminal,
  [Air](https://posit-dev.github.io/air/) for R code formatting, and the
  [Claude Code](https://code.claude.com/docs/en/vs-code) VSCode extension.
- Example report scaffolding: a [{targets}](https://docs.ropensci.org/targets/)
  pipeline, [Quarto child documents](qmd/), and a `references.bib` bibliography.

### Changed

- **Reverted R from 4.6.0 back to 4.5.2.** R 4.6.0 breaks the vscode-R session
  watcher, which makes `View()` fail on `{gt}` tables and other HTML widgets
  inside the devcontainer
  ([#20](https://github.com/ketchbrookanalytics/quarto-pdf-dev/issues/20),
  upstream [vscode-R#1696](https://github.com/REditorSupport/vscode-R/issues/1696)).
  A fix exists in the vscode-R development release; R can move back to 4.6.x once
  that ships to the marketplace.
- Bumped `{renv}` to 1.2.3.
- Collapsed the project `Dockerfile` from a multi-stage build to a single stage
  built `FROM` the published base image.
- Bumped the workflow's GitHub Actions to their Node 24 majors.
- Figures may now break across pages in Typst PDFs.

### Fixed

- `View()` on a `{gt}` table no longer errors with "unable to start data viewer"
  in the devcontainer (see the R revert above).
- The weekly base-image rebuild now actually rebuilds. It was restoring every
  layer from the GitHub Actions cache -- `apt-get install` included -- and
  finishing in 33 seconds, so no OS/security patch ever reached the published
  image despite the manifest digest changing each week. Scheduled runs now build
  cache-less, which also verifies the base still builds from scratch the way a
  new user builds it. Push and manual builds keep the cache.
- `arf` and the REditorSupport extension now share a session, so objects created
  in the `arf` terminal appear in the VSCode R workspace viewer.
- `arf` and `pak::pkg_install()` no longer run in parallel during
  `postCreateCommand`, which could race.
- `PostCreate.sh` is forced to LF line endings, so the devcontainer builds from a
  Windows clone.

## [0.1.0] - 2026-04-14

Initial release.

[Unreleased]: https://github.com/ketchbrookanalytics/quarto-pdf-dev/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/ketchbrookanalytics/quarto-pdf-dev/releases/tag/v0.1.0
