FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Update
RUN apt-get update -qq

# Set specs for `ttf-mscorefonts-installer`
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

# Install `ttf-mscorefonts-installer` and `fontconfig`
# These packages allow us to use Windows system fonts on Ubuntu
RUN apt-get -y install --no-install-recommends ttf-mscorefonts-installer fontconfig

# Add Windows fonts to system fonts cache
RUN fc-cache -f
