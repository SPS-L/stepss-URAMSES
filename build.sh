#!/usr/bin/env bash
# build.sh – rebuild ramses.so inside Docker
set -e
docker compose run --rm uramses-build
echo "ramses.so is at: $(pwd)/output/ramses.so"
