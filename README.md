# PDF Reports with Quarto and Docker

This repository provides a template framework for authoring PDF reports with [Quarto](https://quarto.org/) inside of a [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers), as well as deploying them as reproducible software artifacts via [Docker]().

> [!NOTE]
> This has been tested on both AMD64 and ARM64 architectures.

## Development

We recommend utilizing VSCode Devcontainers while developing the report.

### Setup

We assume that you have Git, Docker, and VSCode installed.

1. Clone this repository to your local machine.
2. Ensure that Docker is running.
3. Open the newly cloned folder containing this repository in VSCode.
4. You should see a popup message in VSCode letting you know that this folder contains a Dev Container configuration file. Click "Reopen in Container".

This will build the Docker image locally (which will take a few minutes the first time you do this) and then spin up a Docker container that will serve as your development environment in VSCode. You can continue working in VSCode as you normally would! If you make changes to any of the files in the [.devcontainer/](.devcontainer/) directory, you will need to rebuild the image.

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

## Deployment

### Pre-Deployment Steps

Before you formally handoff your work to someone else, you'll want to use {renv} to lock down the versions of the R packages you used (as evidenced in the `prod` stage of the multi-stage build in the [Dockerfile](Dockerfile)) so that the work is *fully reproducible*. In order to do so, run the following commands in an R terminal:

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

Commit and push the changes to the repository. You're now ready to hand off this repository to others who want to reproduce your work.

## Reproduction

An end user who wants to reproduce the report will have to perform the following steps:

1. Clone the repository locally.
1. Add git-ignored files to the local clone of the repository (e.g., `data/` files).
1. Build the Docker image
1. Run the Docker container

Steps 3 and 4 are further explained below.

### Build the Docker Image

In order to build the Docker image that contains all of the project's dependencies, run the following command from a bash/shell terminal:

```bash
docker build --target prod -t ketchbrook/report .
```

The above command builds the *prod* Docker image from the specified `Dockerfile`, and tags it with a name you can use later, such as `ketchbrook/report`.

### Run the Docker Container

```bash
docker run --rm -v "$(pwd)/data:/project/data:ro" -v "$(pwd)/_output:/project/_output" ketchbrook/report
```

The above command runs a Docker container based upon the built `ketchbrook/report` image (containing all of our dependencies) and executes the command at the end of the Dockerfile, which **generates the model validation report in a new directory called `_output/`**.

The middle lines of the above command represent communication between our local filesystem and the container (which by default has no access to your local filesystem).

- `-v "$(pwd)/data:/project/data:ro"` allows the container "Read-only" access to the local folder named `data/` in the current working directory. This is only necessary if you have a git-ignored folder called `data/` locally.
- `-v "$(pwd)/_output:/project/_output"` allows the container to write to a folder (which may or may not already exist; if it doesn't exist, it will be created) named `_output/` in the current working directory.

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
- [Dockerfile](Dockerfile) serves as the base Docker image that [devcontainer.json](.devcontainer/devcontainer.json) builds upon, as well as additional *prod* dependencies for deployment purposes at the conclusion of the project. It contains the major dependencies (R, Quarto, and Chrome) needed for the project.
- [report.qmd](report.qmd) is an example Quarto report that showcases how to include tables, plots, and diagrams.