FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Quarto notes that getting Mermaid to work with Docker is non-trivial since
# they use Puppeteer + Chromium for image conversion. See the following links:
# - https://quarto.org/docs/authoring/diagrams.html#chrome-install
# - https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#running-puppeteer-in-docker

# Following the second link, let's set up the necessary dependencies to get
# Mermaid & Typst to play nicely together

# Install latest chrome dev package and fonts to support major charsets
# (Chinese, Japanese, Arabic, Hebrew, Thai and a few others).
# Note: this installs the necessary libs to make the bundled version of Chrome
# for Testing that Puppeteer installs, work.
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install Chromium from Ubuntu repos (lighter weight) and update system deps
# for R packages
RUN apt-get update && apt-get install -y \
    chromium-browser \
    && rm -rf /var/lib/apt/lists/*