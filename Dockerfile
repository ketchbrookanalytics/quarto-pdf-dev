# Define the version of R that we'll be using
ARG R_VERSION=4.6.0

# Use the rocker/verse base image to install the specific version of R
FROM rocker/r-ver:${R_VERSION} AS dev

# Define the versions of the other software dependencies we'll be using
ARG QUARTO_VERSION=1.9.38

# Install fonts, along with the shared libraries that Chrome Headless Shell
# (installed below) needs at runtime to render mermaid/graphviz diagrams.
RUN apt-get update && apt-get install --no-install-recommends -y \
    fonts-roboto \
    wget \
    libnss3 \
    libnspr4 \
    libatk1.0-0t64 \
    libatk-bridge2.0-0t64 \
    libatspi2.0-0t64 \
    libdbus-1-3 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libxkbcommon0 \
    libasound2t64 \
    libgbm1 \
    libcups2t64 \
    libpango-1.0-0 \
    libcairo2 \
  && rm -rf /var/lib/apt/lists/*

# Install Quarto, along with Chrome Headless Shell - Quarto's purpose-built
# headless browser (Chrome for Testing) used to render mermaid/graphviz
# diagrams. It ships native arm64 and amd64 Linux builds and needs no system
# Chrome/Chromium package, unlike the apt-based Chrome install this replaced.
ARG TARGETARCH
RUN wget -q "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${TARGETARCH}.deb" \
  && dpkg -i "quarto-${QUARTO_VERSION}-linux-${TARGETARCH}.deb" \
  && rm "quarto-${QUARTO_VERSION}-linux-${TARGETARCH}.deb" \
  && quarto install chrome-headless-shell --no-prompt

# Install the latest version of {pak}
RUN R -q -e "install.packages('pak')"

# Ensure we use {pak} on the backend with {renv} to install the packages in the
# lock file
ENV RENV_CONFIG_PAK_ENABLED=true

# Ensure we properly isolate "dev" packages installed in the Dev Container
ENV RENV_CONFIG_SANDBOX_ENABLED=false

# Don't automatically compare installed packages to lock file every new R
# session
ENV RENV_CONFIG_SYNCHRONIZED_CHECK=false

# Define the version of {renv} to install
ARG RENV_VERSION=1.1.7

# Install {renv}
# Note that we won't use {renv} to install packages during development;
# conversely, we'll use {pak}. We'll only use {renv} during the pre-deployment
# process (see README for further instructions).
RUN R -q -e "pak::pkg_install('rstudio/renv@v${RENV_VERSION}')"

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
