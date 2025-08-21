FROM browserless/chrome

# install system dependency for pak
USER root
RUN apt-get update && apt-get install -y \
  # {Matrix}
  gfortran \
  # {pak}
  libcurl4-openssl-dev \
  # {systemfonts}
  libfontconfig1-dev \
  # {nlme}
  liblapack-dev libblas-dev \
  # {xml2}
  libxml2-dev \
  && rm -rf /var/lib/apt/lists/*