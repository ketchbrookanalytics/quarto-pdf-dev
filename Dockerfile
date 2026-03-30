# Define the version of R that we'll be using
ARG R_VERSION=4.5.2

# Use the rocker/verse base image to install the specific version of R
FROM rocker/r-ver:${R_VERSION} AS dev

# Define the versions of the other software dependencies we'll be using
ARG QUARTO_VERSION=1.8.27

# Install fonts
RUN apt-get update && apt-get install --no-install-recommends -y \
    fonts-roboto \
  && rm -rf /var/lib/apt/lists/*

# Install Chrome
RUN apt-get update && apt-get install --no-install-recommends -y \
    wget \
    gnupg2 \
  && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
     > /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update && apt-get install --no-install-recommends -y \
    google-chrome-stable \
  && rm -rf /var/lib/apt/lists/*

# Install Quarto
RUN wget -q "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
  && dpkg -i "quarto-${QUARTO_VERSION}-linux-amd64.deb" \
  && rm "quarto-${QUARTO_VERSION}-linux-amd64.deb"

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
