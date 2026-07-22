#!/usr/bin/env bash
set -e

echo "==> Installing system dependencies for arf..."
apt-get update -qq
apt-get install -y -qq curl xz-utils

echo "==> Installing arf R terminal..."
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/eitsupi/arf/releases/latest/download/arf-console-installer.sh | sh

if [ "$#" -eq 0 ]; then
  echo "==> No R packages specified, skipping pak install."
else
  echo "==> Installing R packages via pak: $*"
  packages=$(printf "'%s', " "$@")
  packages="${packages%, }"
  R -q -e "pak::pkg_install(c(${packages}))"
fi

echo "==> ✅ postCreateCommand complete."
