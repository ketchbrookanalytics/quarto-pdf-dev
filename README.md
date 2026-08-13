# PDF Reports with Quarto and Docker

This repository provides a template framework for authoring PDF reports with [Quarto](https://quarto.org/) inside of a [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers), as well as deploying them as reproducible software artifacts via [Docker]().

> [!NOTE]
> This repository has been tested on both AMD64 and ARM64 architectures.

## Development

We recommend utilizing VSCode Devcontainers while developing the report.

### Setup

We assume that you have Git, Docker, and VSCode installed.

1. Clone this repository to your local machine.
2. Ensure that Docker is running.
3. Open the newly cloned folder containing this repository in VSCode.
4. You should see a popup message in VSCode letting you know that this folder contains a Dev Container configuration file. Click "Reopen in Container".

If you don't see the popup, you can also reopen in container via the VSCode Command Palette:
- Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac) to open the Command Palette.
- Search for "Dev Containers: Reopen in Container" and select it.

This will pull the pre-built base image from `ghcr.io/ketchbrookanalytics/quarto-pdf-dev` (which will take a minute the first time you do this) and then spin up a Docker container that will serve as your development environment in VSCode. You can continue working in VSCode as you normally would! If you make changes to any of the files in the [.devcontainer/](.devcontainer/) directory, you will need to rebuild the container.

### Why Devcontainers?

Devcontainers in VSCode allow you to work inside of a Docker container. For us, there are two main advantages to this approach:

1. At the end of a project, the software dependencies I had to install specifically for that project don't hang around. All dependencies (including R, Quarto, R packages, etc.) are part of the Docker image, which I can delete from my local machine at the project's conclusion.
2. Devcontainers allow our team at Ketchbrook Analytics to collaborate with each other quickly & effectively, since we can be certain that all team members involved on a project are working within the *exact* same operating system and software environment. This reduces a *lot* of friction that previously existed around managing versions project dependencies.

### Rendering the Report

To render the [example report](report.qmd), simply run the following command from a bash/shell terminal:

```bash
quarto render
```

Then check the newly-created `_output/` directory, where you should find a `report.pdf` file.

### Adding New R Packages

As you develop, you'll likely have the need to install additional R packages. In order to do so in a way that allows multiple developers to track the project's R package dependencies, all R packages used should be listed in the `r-packages` `postCreateCommand` in [devcontainer.json](.devcontainer/devcontainer.json).

### Features

The devcontainer also offers the following additional features:

- The [arf](https://github.com/eitsupi/arf) R terminal for a friendly R console experience that includes auto-complete and syntax highlighting.
- Use of [Air](https://posit-dev.github.io/air/) for R code formatting.
- [Claude Code](https://code.claude.com/docs/en/vs-code) VSCode extension for AI-assisted development.

### Recommended Claude Code Plugins

Reports written from this template are read by clients, auditors, and examiners, so the prose matters as much as the numbers. We recommend installing [SimpleEnglish](https://github.com/AminBlg/SimpleEnglish), a plugin that applies [ASD-STE100 Simplified Technical English](https://www.asd-ste100.org/): short sentences, one word with one meaning, active voice, and the condition stated before the instruction.

Install it once per machine from a Claude Code session:

```
/plugin marketplace add AminBlg/SimpleEnglish
/plugin install simple-english@simple-english
```

Then ask Claude to apply it when drafting or revising narrative sections.

> [!NOTE]
> Plugins install per machine, not per repository, so each person working on a report installs this themselves. It is deliberately not baked into the [devcontainer](.devcontainer/) — the image pins a *dependency stack* that has to render identically years from now, and a writing-style plugin that updates on its own doesn't belong in that guarantee.

## Deployment

### Pre-Deployment Steps

Before you formally handoff your work to someone else, you'll want to use {renv} to lock down the versions of the R packages you used (installed via `renv::restore()` in the [Dockerfile](Dockerfile)) so that the work is *fully reproducible*. In order to do so, run the following commands in an R terminal:

```r
# Initialize {renv}
renv::init(bare = TRUE)   # Answer "y" / "Yes", then restart R

# Allow {renv} to use the already installed version of {pak}
renv::hydrate(packages = "pak")   # Answer "Y" / "Yes"

# Enable `renv::dependencies()` (it requires {yaml} be installed)
renv::install("yaml")

# Discover project R package dependencies
deps <- unique(renv::dependencies()$Package)

# Install R package dependencies for the project
renv::install(deps[deps != "renv"])   # Select "Y" or "Yes"

# Create the renv.lock lockfile
# Note: if prompted to first install additional required packages, follow the
# directions to do so via `renv::install()` prior to re-running renv::snapshot()
renv::snapshot()

```

The resulting `renv.lock` file will be used by Docker during build time to install the exact R package dependencies used in the project via `renv::restore()`.

For a *fully* reproducible build, also pin the base image at this point. The [Dockerfile](Dockerfile) references `ghcr.io/ketchbrookanalytics/quarto-pdf-dev:latest`, which tracks the newest base. Replace `:latest` with a released version tag so the R/Quarto versions can't drift after handoff:

```dockerfile
FROM ghcr.io/ketchbrookanalytics/quarto-pdf-dev:v0.2.0
```

Available tags are listed on the [package page](https://github.com/ketchbrookanalytics/quarto-pdf-dev/pkgs/container/quarto-pdf-dev), and each release's dependency stack is recorded in [CHANGELOG.md](CHANGELOG.md). See [Versioning & Releases](#versioning--releases) below for what the tags mean.

Commit and push the changes to the repository. You're now ready to hand off this repository to others who want to reproduce your work.

## Reproduction

An end user who wants to reproduce the report will have to perform the following steps:

1. Clone the repository locally.
1. Add git-ignored files to the local clone of the repository (e.g., `data/` files).
1. Build the Docker image
1. Run the Docker container

Steps 3 and 4 are further explained below.

### Build the Docker Image

> [!IMPORTANT]
> This step must be run **outside the devcontainer** (e.g., in your native terminal, not inside VS Code).

In order to build the Docker image that contains all of the project's dependencies, run the following command from a bash/shell terminal:

```bash
docker build -t ketchbrook/report .
```

The above command builds the deployment Docker image from the specified `Dockerfile`, and tags it with a name you can use later, such as `ketchbrook/report`.

### Run the Docker Container

```bash
docker run --rm -v "$(pwd)/data:/project/data:ro" -v "$(pwd)/_output:/project/_output" ketchbrook/report
```

The above command runs a Docker container based upon the built `ketchbrook/report` image (containing all of our dependencies) and executes the command at the end of the Dockerfile, which **generates the model validation report in a new directory called `_output/`**.

The middle lines of the above command represent communication between our local filesystem and the container (which by default has no access to your local filesystem).

- `-v "$(pwd)/data:/project/data:ro"` allows the container "Read-only" access to the local folder named `data/` in the current working directory. This is only necessary if you have a git-ignored folder called `data/` locally.
- `-v "$(pwd)/_output:/project/_output"` allows the container to write to a folder (which may or may not already exist; if it doesn't exist, it will be created) named `_output/` in the current working directory.

## Versioning & Releases

This template's real product is a *pinned dependency stack* — a specific R version, a specific Quarto version, and the tooling around them. Those dependencies get updated periodically, and occasionally an update has to be walked back (as with the R 4.6.0 → 4.5.2 revert in [#20](https://github.com/ketchbrookanalytics/quarto-pdf-dev/issues/20)). Releases exist so a project handed off six months ago can name the exact stack it was built against.

### Image tags

The base image at `ghcr.io/ketchbrookanalytics/quarto-pdf-dev` carries four kinds of tag:

| Tag | Moves? | Use it for |
| --- | --- | --- |
| `v0.2.0`, `0.2.0` | Never | **Handoffs.** Pins one exact dependency stack. |
| `0.2` | On patch re-releases | Tracking fixes within a minor line. |
| `latest` | Every build of `main`, including the weekly rebuild | **Active development.** Gets OS/security patches automatically. |
| `sha-abc1234` | Never | Tracing a specific image back to a commit. |

The [devcontainer](.devcontainer/) and an in-flight project's [Dockerfile](Dockerfile) should stay on `:latest`, so ongoing work picks up patches. Pin to `vX.Y.Z` only at handoff, alongside locking `renv.lock`.

`latest` and the semver tags are only applied *after* the smoke test passes on both architectures, so a build that can't render never becomes anyone's `latest` — it just leaves those tags on the previous image. `sha-` tags are the exception: they are pushed before the test runs, so one exists for every build including failed ones. Pin a released `vX.Y.Z`, not a `sha-`.

> [!NOTE]
> The weekly rebuild runs cache-less on purpose, so it takes on the order of ten minutes rather than seconds. A scheduled run that finishes in well under a minute means the cache is being restored and **no patches are landing** — the manifest digest still changes every week regardless, because of the image's `created` timestamp label, so digest churn is not evidence of a real rebuild.
>
> Every build is smoke-tested by rendering [report.qmd](report.qmd) inside the image ([.github/scripts/smoke-test.sh](.github/scripts/smoke-test.sh)), on `linux/amd64` and `linux/arm64`, each on a native runner. The same script is a handy way to reproduce a suspected image problem locally:
>
> ```bash
> docker run --rm -v "$PWD:/project" -w /project \
>   ghcr.io/ketchbrookanalytics/quarto-pdf-dev:latest \
>   bash .github/scripts/smoke-test.sh
> ```
>
> Add `--platform linux/arm64` to reproduce an arm64 problem, but do it on arm64 hardware. Under QEMU emulation the render fails when Quarto drives Chrome Headless Shell (`AssertionError` … `Child process has already terminated`) even when the image itself is fine — the identical render passes with the mermaid diagrams removed. That is why CI smoke-tests arm64 on a native runner rather than through the emulation layer it builds with.
>
> Note what the weekly rebuild does *not* refresh: packages baked into the `rocker/r-ver` parent image stay frozen until either Rocker republishes that tag or we bump `R_VERSION`. Only the layers `Dockerfile.base` builds itself — the `apt-get` installs, Quarto, Chrome Headless Shell, `{pak}`, `{renv}` — get picked up fresh.

### What bumps which number

| Change | Bump |
| --- | --- |
| A dependency change that can invalidate an existing `renv.lock` — an R minor-version jump (`4.5.x` → `4.6.x`), which changes the binary package line | **Major** |
| Anything else that changes the dependency stack: R patch versions, Quarto versions, `{renv}` versions, new system libraries, new devcontainer tooling | **Minor** |
| Docs, workflow plumbing, Typst/template tweaks, and fixes that leave the dependency stack untouched | **Patch** |

A revert counts as a change: moving R back down is a **minor** bump forward, not a rollback to an older version number.

### Cutting a release

1. Move the `## [Unreleased]` entries in [CHANGELOG.md](CHANGELOG.md) under a new `## [X.Y.Z] - YYYY-MM-DD` heading, confirm the dependency-stack line at the top of the section matches [Dockerfile.base](Dockerfile.base), and update the link definitions at the bottom of the file.
2. Merge to `main` and wait for the [publish workflow](.github/workflows/publish-image.yml) to go green. Its three jobs run in order: `publish` builds and pushes the `sha-` tag, `smoke` renders the report on both architectures, and `promote` then moves `latest`. If `smoke` fails, nothing is promoted — fix the image before releasing.
3. Publish the release, which triggers the workflow again to stamp the semver tags:

    ```bash
    gh release create vX.Y.Z --title vX.Y.Z --notes "See CHANGELOG.md for details."
    ```

4. Confirm the new tags appear on the [package page](https://github.com/ketchbrookanalytics/quarto-pdf-dev/pkgs/container/quarto-pdf-dev).

## Structure

This repository contains the following components:

- [_targets/](_targets/) contains [{targets}](https://docs.ropensci.org/targets/) pipeline metadata.
- [.claude/](.claude/) contains specific instructions and permission settings for Claude Code.
- [devcontainer.json](.devcontainer/devcontainer.json) builds upon the [Dockerfile](Dockerfile) by incorporating additional features into the development environment.
- [assets/](assets/) contains custom [Typst](https://quarto.org/docs/output-formats/typst.html) specifications.
    + [typst-template.typ](assets/typst-template.typ) outlines the [Typst template](https://typst.app/docs/tutorial/making-a-template/) that is used to create the report.
    + [typst-show.typ](assets/typst-show.typ) details the mapping of Pandoc metatdata to function arguments in [typst-template.typ](assets/typst-template.typ).
    + [www/](assets/www/) contains the proprietary images we use on the cover page of our reports.
- [qmd/](qmd/) contains the [Quarto child documents](https://quarto.org/docs/authoring/includes.html) that make up most of the report narrative and detail.
- [_quarto.yml](_quarto.yml) specifies the different [options](https://quarto.org/docs/reference/formats/typst.html) Quarto provides for rendering Typst PDF documents, and also passes variables to [typst-show.typ](assets/typst-show.typ) which, in turn, passes values to [typst-template.typ](assets/typst-template.typ).
- [air.toml](air.toml) instantiates the project's use of [Air](https://posit-dev.github.io/air/) for R code formatting.
- [CHANGELOG.md](CHANGELOG.md) records what changed in each release of the template, including the R/Quarto/`{renv}` versions that release ships.
- [Dockerfile.base](Dockerfile.base) defines the reusable `dev` base image (R, Quarto, Chrome Headless Shell, `pak`, `renv`). It is published to `ghcr.io/ketchbrookanalytics/quarto-pdf-dev` by [.github/workflows/publish-image.yml](.github/workflows/publish-image.yml) and is shared, unchanged, across every report project.
- [Dockerfile](Dockerfile) builds the project-specific deployment image directly on top of that published base (adding `assets/`, `qmd/`, `renv::restore()`, etc.) at the conclusion of the project.
- [report.qmd](report.qmd) is an example Quarto report that showcases how to include tables, plots, and diagrams.