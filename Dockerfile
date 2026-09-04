# The reusable "dev" base image (R + Quarto + Chrome Headless Shell + pak +
# renv) is pre-built from Dockerfile.base and published to ghcr.io by
# .github/workflows/publish-image.yml, so new repos no longer rebuild it.
#
# ":latest" always tracks the newest base, so an in-flight project picks up
# OS/security patches from the weekly rebuild. For a fully reproducible build,
# pin this to a released version tag (e.g. ":v0.2.0") at handoff, alongside
# locking renv.lock. See the README's "Pre-Deployment Steps" and
# "Versioning & Releases" sections.
FROM ghcr.io/ketchbrookanalytics/quarto-pdf-dev:latest

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
COPY .Rprofile          .Rprofile
COPY renv/activate.R    renv/activate.R
COPY renv/settings.json renv/settings.json
COPY report.qmd     report.qmd

# Install the R packages in the lock file
# This should use {pak} and install system packages, too
RUN R -q -e "renv::restore()"

# Render the report
CMD ["quarto", "render"]
