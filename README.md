# PDF Reports with Quarto inside a Devcontainer

This repository provides a template framework for authoring PDF reports with [Quarto](https://quarto.org/) inside of a [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers).

## Getting Started

We assume that you have Git, Docker, and VSCode installed.

1. Clone this repository to your local machine.
2. Ensure that Docker is running.
3. Open the newly cloned folder containing this repository in VSCode.
4. You should see a popup message in VSCode letting you know that this folder contains a Dev Container configuration file. Click "Reopen in Container".

This will build the Docker image locally (which will take a few minutes the first time you do this) and then spin up a Docker container that will serve as your development environment in VSCode. You can continue working in VSCode as you normally would! If you make changes to any of the files in the [.devcontainer/](.devcontainer/) directory, you will need to rebuild the image.

### Rendering the Report

To render the [example report](my-awesome-report.qmd), run `quarto render my-awesome-report.qmd` from the terminal, and check the newly-created `_output/` directory once it finishes knitting.

## Why Devcontainers?

Devcontainers in VSCode allow you to work inside of a Docker container. For us, there are two main advantages to this approach:

1. At the end of a project, the software dependencies I had to install specifically for that project don't hang around. All dependencies (including R, Quarto, R packages, etc.) are part of the Docker image, which I can delete from my local machine at the project's conclusion.
2. Devcontainers allow our team at Ketchbrook Analytics to collaborate with each other quickly & effectively, since we can be certain that all team members involved on a project are working within the *exact* same operating system and software environment. This reduces a *lot* of friction that previously existed around managing versions of R, R packages, Quarto, etc.

## Structure

This repository contains the following components:

* [.devcontainer/](.devcontainer/) contains two files:
    + [devcontainer.json](.devcontainer/devcontainer.json) serves as the overall specification of the development environment. Any additional R packages needed can be installed by adding a `r-cran-<package>` to line 29.
    + [Dockerfile](.devcontainer/Dockerfile) serves as the base Docker image that [devcontainer.json](.devcontainer/devcontainer.json) builds upon.
        + The Dockerfile specifies a Ubuntu image with Windows system fonts installed, so that we can use fonts that are more familiar with the target audience (e.g., Arial, Times New Roman, etc.) in our reports than the Ubuntu system fonts.
* [assets/](assets/) contains the LaTeX scripts that help format the cover page of the report.
    + [_titlepage.tex](assets/_titlepage.tex) specifies the design of the cover page.
    + [before-body.tex](assets/before-body.tex) tells Quarto to put the cover page before everything else.
    + [in-header.tex](assets/in-header.tex) installs the pandoc libraries needed for the cover page design.
    + [www/](assets/www/) contains the proprietary images we use on the cover page of our reports.
* [quarto.yml](quarto.yml) specifies the different [options](https://quarto.org/docs/reference/formats/pdf.html) Quarto provides for rendering PDF documents, and also passes variables to [_titlepage.tex](assets/_titlepage.tex).
* [my-awesome-report.qmd](my-awesome-report.qmd) is an example Quarto report that showcases how to include LaTeX-style tables, plots, and mermaidjs diagrams.

## Future Work

There are a *million* different ways to configure your development environment. In future work on this template repository, we plan to showcase more of these options, such as:

* configuring keyboard shortcuts in your [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) file, such as a shortcut for the R base `|>` operator
* using {renv} for a more strict approach to R package version management
* ... and more!
