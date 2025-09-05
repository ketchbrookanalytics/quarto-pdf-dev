FROM browserless/chrome

# install system dependency for pak
USER root
RUN apt-get update && apt-get install -y \
  # {Matrix}
  gfortran \
  libblas-dev \
  liblapack-dev \
  && rm -rf /var/lib/apt/lists/*