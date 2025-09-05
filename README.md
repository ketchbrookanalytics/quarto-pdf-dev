# PDF Reports with Quarto inside a Devcontainer

This repository provides a template framework for authoring PDF reports with [Quarto](https://quarto.org/) inside of a [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers).

## Getting Started

We assume that you have Git, Docker, and VSCode installed.

1. Clone this repository to your local machine.
2. Ensure that Docker is running.
3. Open the newly cloned folder containing this repository in VSCode.
4. You should see a popup message in VSCode letting you know that this folder contains a Dev Container configuration file. Click "Reopen in Container".

This will build the Docker image locally (which will take a few minutes the first time you do this) and then spin up a Docker container that will serve as your development environment in VSCode. You can continue working in VSCode as you normally would! If you make changes to any of the files in the [.devcontainer/](.devcontainer/) directory, you will need to rebuild the image.

### Architecture Support

This has been tested on both AMD64 and ARM64 architectures.

### Rendering the Report

To render the [example report](my-awesome-report.qmd), run `quarto render my-awesome-report.qmd` from the terminal, and check the newly-created `_output/` directory once it finishes knitting.

## Why Devcontainers?

Devcontainers in VSCode allow you to work inside of a Docker container. For us, there are two main advantages to this approach:

1. At the end of a project, the software dependencies I had to install specifically for that project don't hang around. All dependencies (including R, Quarto, R packages, etc.) are part of the Docker image, which I can delete from my local machine at the project's conclusion.
2. Devcontainers allow our team at Ketchbrook Analytics to collaborate with each other quickly & effectively, since we can be certain that all team members involved on a project are working within the *exact* same operating system and software environment. This reduces a *lot* of friction that previously existed around managing versions of R, R packages, Quarto, etc.

## Structure

This repository contains the following components:

* [.devcontainer/](.devcontainer/) contains two files:
    + [devcontainer.json](.devcontainer/devcontainer.json) serves as the overall specification of the development environment. Any additional R packages needed can be installed by adding it to the list on line 25.
    + [Dockerfile](.devcontainer/Dockerfile) serves as the base Docker image that [devcontainer.json](.devcontainer/devcontainer.json) builds upon.
        + The Dockerfile installs several system dependency for [pak](https://pak.r-lib.org/), an R package installer.
* [assets/](assets/) contains the [Typst](https://quarto.org/docs/output-formats/typst.html) files that help create the report.
    + [typst-template.typ](assets/typst-template.typ) outlines the [Typst template](https://typst.app/docs/tutorial/making-a-template/) that is used to create the report.
    + [typst-show.typ](assets/typst-show.typ) details the mapping of Pandoc metatdata to function arguments in [typst-template.typ](assets/typst-template.typ).
    + [www/](assets/www/) contains the proprietary images we use on the cover page of our reports.
* [_quarto.yml](_quarto.yml) specifies the different [options](https://quarto.org/docs/reference/formats/typst.html) Quarto provides for rendering PDF documents, and also passes variables to [typst-show.typ](assets/typst-show.typ) which, in turn, passes values to [typst-template.typ](assets/typst-template.typ).
* [my-awesome-report.qmd](my-awesome-report.qmd) is an example Quarto report that showcases how to include Typst-style tables, plots, and mermaidjs diagrams.

## Using {renv}

If you want to leverage [{renv}](https://rstudio.github.io/renv/index.html) for greater reproducibility and caching of R packages for faster Docker re-build speeds, we have developed an opinionated approach using the [renv-cache feature](https://github.com/rocker-org/devcontainer-features/tree/main/src/renv-cache), {renv}, and [{pak}](https://pak.r-lib.org/).

### Setting Up the {renv} approach

1. Create an `.Renviron` file at the root of this repository containing the line `RENV_CONFIG_PAK_ENABLED=true`
    + This enables {renv} to use {pak} on the backend for package installation. The benefit of {pak} is that it (a) ensures R package binaries are installed when available and (b) identifies and installs system package dependencies of the R packages you are installing.
1. Re-build and re-open the Dev Container.
1. In an R console, run `renv::init(bare = TRUE)` to set up the {renv} project without discovering and automatically installing R package dependencies of your project.
    + `renv::init()` will not install packages via {pak}, though `renv::install()` will.
    + You will be prompted to start a new R session. The easiest way to do this is to kill the existing R terminal and create a new R terminal.
1. To install the initial R packages that this template repository depends on, run `renv::install(c("dplyr", "ggplot2", "github::nx10/httpgd", "languageserver", "rmarkdown"))` from the new R terminal.
1. To snapshot these packages & associated versions in an `renv.lock` lock file, run `renv::snapshot()`.
1. As you develop and you need to leverage more R packages in your project, run `renv::install("<package_name>")` to install them and then `renv::snapshot()` to memorialize them in the `renv.lock` lock file.

## Future Work

There are a *million* different ways to configure your development environment. In future work on this template repository, we plan to showcase more of these options, such as:

* configuring keyboard shortcuts in your [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) file, such as a shortcut for the R base `|>` operator
* ... and more!
