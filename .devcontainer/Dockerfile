FROM browserless/chrome

# install system dependency for pak
USER root
RUN apt-get update && apt-get install -y \
  libcurl4-openssl-dev \
  libxml2-dev \
  libfontconfig1-dev \
  && rm -rf /var/lib/apt/lists/*