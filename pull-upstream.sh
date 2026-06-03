#!/usr/bin/env bash

set -euo pipefail

git checkout nixos-25.11
git reset --hard upstream/nixos-25.11
git pull upstream nixos-25.11 --depth 1 --force --rebase
git reset --hard upstream/nixos-25.11
git push origin nixos-25.11 --force

git checkout nixos-25.11-dev
git pull origin nixos-25.11 --rebase
git push origin nixos-25.11-dev --force
