#!/usr/bin/env bash
# Smoke-test the "dev" base image by rendering the example report inside it, the
# way a brand-new user would. Run from the repository root, in a container built
# from Dockerfile.base:
#
#   docker run --rm -v "$PWD:/project" -w /project <image> \
#     bash .github/scripts/smoke-test.sh
#
# Rendering report.qmd exercises nearly everything the base image adds on top of
# R: {pak} installing packages (with its own apt-get sysreqs pass), the knitr
# engine, Quarto's Typst PDF backend, Chrome Headless Shell for the mermaid
# diagrams in qmd/_03_diagrams.qmd, and the Roboto and colour-emoji fonts that
# report.qmd and the {gt} tables ask for. A build that succeeds but produces an
# image where any of that is broken fails here instead of in a devcontainer.
#
# This script writes to the working tree (_output/, _targets/objects/, .quarto/),
# all of which are git-ignored.
set -euo pipefail

# Keep in sync with the "r-packages" arguments to postCreate.sh in
# .devcontainer/devcontainer.json. The dev-only packages listed there (httpgd,
# languageserver) are omitted; knitr and rmarkdown are named explicitly because
# Quarto's knitr engine needs them and the devcontainer only gets them
# transitively.
PACKAGES="'ggplot2', 'gt', 'knitr', 'rmarkdown', 'targets', 'tibble'"

echo "==> Versions"
R --version | head -1
echo "Quarto $(quarto --version)"

echo "==> Installing R packages via pak"
R -q -e "pak::pkg_install(c(${PACKAGES}))"

echo "==> Rendering report.qmd"
# The pre-render hook in _quarto.yml runs targets::tar_make() first, building
# the {gt} table and {ggplot2} plot that the report reads back with tar_read().
# _targets/objects/ is git-ignored, so this always rebuilds from scratch here.
quarto render report.qmd

echo "==> Verifying output"
PDF=_output/report.pdf

if [ ! -f "$PDF" ]; then
  echo "FAIL: $PDF was not created"
  exit 1
fi

# Check the magic bytes and size rather than mere existence: a Typst backend
# that half-failed could still leave a stub file behind.
if ! head -c 4 "$PDF" | grep -qa '%PDF'; then
  echo "FAIL: $PDF exists but is not a PDF"
  exit 1
fi

bytes=$(wc -c < "$PDF")
if [ "$bytes" -lt 20000 ]; then
  echo "FAIL: $PDF is only ${bytes} bytes; expected a multi-page report"
  exit 1
fi

echo "==> OK: rendered $PDF (${bytes} bytes)"
