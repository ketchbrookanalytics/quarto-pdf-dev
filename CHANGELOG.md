# Changelog

All notable changes to this template are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to the versioning policy documented in the
[README](README.md#versioning--releases).

Because the pinned dependency stack (R, Quarto, `{renv}`) *is* the product
here, every release note calls out the versions it ships.

## [Unreleased]

## [0.2.2] - 2026-09-04

Dependency stack: **R 4.5.2**, **Quarto 1.9.38**, **`{renv}` 1.2.3** (unchanged
from 0.2.1)

### Fixed

- The pre-deployment `renv::install(deps[deps != "renv"])` step no longer aborts
  on recommended packages. See
  [#26](https://github.com/ketchbrookanalytics/quarto-pdf-dev/issues/26) for a
  full discussion of the issue, and
  [#27](https://github.com/ketchbrookanalytics/quarto-pdf-dev/pull/27) for the
  fix.
- The deployment [Dockerfile](Dockerfile) now copies `.Rprofile`,
  `renv/activate.R`, and `renv/settings.json`. Without these, nothing placed
  the project library on `.libPaths()`, and `renv::restore()` (with the {pak}
  engine; i.e., `renv:::renv_pak_restore()`) didn't pass any `lib` to `{pak}`,
  so `renv::restore()` installed into `/usr/local/lib/R/site-library` and never
  created a project library at all. That failed silently; the build went
  green and the report rendered, but from a library `renv.lock` did *not*
  govern, which defeated the point of pinning the lock file at handoff.

## [0.2.1] - 2026-08-14

Dependency stack: **R 4.5.2**, **Quarto 1.9.38**, **`{renv}` 1.2.3** (unchanged
from 0.2.0)

### Added

- Permission allow rules in [.claude/settings.json](.claude/settings.json) so
  Claude Code edits the authoring surface without a prompt per file: root
  `*.qmd`, [qmd/](qmd/), [R/](R/), [_targets.R](_targets.R), [assets/](assets/),
  [.devcontainer/](.devcontainer/), [CLAUDE.md](CLAUDE.md), and
  [_quarto.yml](_quarto.yml). `Edit(...)` is the rule namespace for every
  file-modifying tool, so `Write` and `NotebookEdit` are covered by the same
  entries. Everything outside the list — `Dockerfile`, `.github/`, `.gitignore`,
  and `.claude/settings.json` itself — still prompts.
- Allow rules for `quarto render` / `quarto preview` and read-only `git`
  (`status`, `diff`, `log`, `show`), so an iterate-and-render loop does not stop
  on a prompt each pass. Only rules that hold for anyone using this template
  belong here; organization-specific rules (a `gh api` allowance scoped to your
  own GitHub org, for instance) belong in the downstream project repository, not
  in the template.
- A **Recommended Claude Code Plugins** section in the
  [README](README.md#recommended-claude-code-plugins) covering
  [SimpleEnglish](https://github.com/AminBlg/SimpleEnglish), which applies
  [ASD-STE100 Simplified Technical English](https://www.asd-ste100.org/) to the
  narrative sections of a report. Documented rather than vendored, since upstream
  ships its own marketplace manifest, and deliberately left out of the
  devcontainer: plugins install per machine rather than per repository, and a
  writing-style plugin that updates on its own does not belong inside an image
  whose job is to render identically years from now.

### Changed

- `.Renviron` and `data/**` are now denied for editing as well as reading. The
  previous rules blocked reads only, which left a git-ignored secrets file
  overwritable.

## [0.2.0] - 2026-07-28

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
  emoji fonts. Both `linux/amd64` and `linux/arm64` are tested on every build,
  each on a native runner rather than through the QEMU layer used to build them,
  because Chrome Headless Shell cannot render under emulation.
- The smoke test gates publication. The build pushes only a `sha-` tag; `latest`
  and the semver tags are moved onto that image by a separate `promote` job once
  both architectures have rendered the report, so a build that can't render never
  becomes anyone's `latest`.
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

[Unreleased]: https://github.com/ketchbrookanalytics/quarto-pdf-dev/compare/v0.2.2...HEAD
[0.2.2]: https://github.com/ketchbrookanalytics/quarto-pdf-dev/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/ketchbrookanalytics/quarto-pdf-dev/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/ketchbrookanalytics/quarto-pdf-dev/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/ketchbrookanalytics/quarto-pdf-dev/releases/tag/v0.1.0
