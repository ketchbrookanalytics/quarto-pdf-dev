# The reusable "dev" base image (R + Quarto + Chrome Headless Shell + pak +
# renv) is pre-built from Dockerfile.base and published to ghcr.io by
# .github/workflows/publish-image.yml, so new repos no longer rebuild it.
#
# ":latest" always tracks the newest base. For a fully reproducible build,
# pin this to an immutable digest tag (e.g. ":sha-abc1234"); the publish
# workflow tags every build with its commit SHA. Do this at handoff, alongside
# locking renv.lock (see the README's "Pre-Deployment Steps").
FROM ghcr.io/ketchbrookanalytics/quarto-pdf-dev:latest AS dev

# Build upon the dev image (called by the devcontainer) & add prod instructions
FROM dev AS prod

# Set the working directory for the project
WORKDIR /project

# Add local files and folders needed to generate the report
COPY assets/        assets/
COPY qmd/           qmd/
COPY _quarto.yml    _quarto.yml
COPY _targets.R     _targets.R
COPY R/              R/
COPY references.bib references.bib
COPY renv.lock      renv.lock
COPY report.qmd     report.qmd

# Install the R packages in the lock file
# This should use {pak} and install system packages, too
RUN R -q -e "renv::restore()"

# Render the report
CMD ["quarto", "render"]
