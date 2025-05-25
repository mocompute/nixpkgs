#!/usr/bin/env bash

set -euo pipefail

git checkout nixos-25.05
git pull upstream nixos-25.05 --depth 1 --force --rebase
git reset --hard upstream/nixos-25.05
git push origin nixos-25.05 --force

git checkout nixos-25.05-dev
git pull origin nixos-25.05 --rebase
git push origin nixos-25.05-dev --force
