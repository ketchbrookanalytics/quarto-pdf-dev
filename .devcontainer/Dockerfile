FROM browserless/chrome

# install system dependency for pak
USER root
RUN apt-get update && apt-get install -y \
  # {pak}
  libcurl4-openssl-dev \
  libxml2-dev \
  libfontconfig1-dev \
  liblapack-dev libblas-dev \
  libxml2-dev \
  && rm -rf /var/lib/apt/lists/*