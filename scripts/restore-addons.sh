#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# Current dependency truth: installed addon trees are disposable/generated, and
# some upstream addon sources still do not ship every Godot 4.4-generated .uid
# file. After an import/test run, rerunning raw `godotenv addons install` can
# therefore abort on dirty ignored files inside addons/ or .addons/.
#
# Keep the repo-local restore flow repeatable by clearing the generated install
# targets first, then reacquiring the manifest-defined addons.
rm -rf addons .addons

godotenv addons install "$@"
