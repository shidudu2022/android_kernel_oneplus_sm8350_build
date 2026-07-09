#!/usr/bin/env bash
set -euo pipefail

RELEASE_TAG="${1:?Usage: publish-to-release.sh <tag> <title> <artifact-dir>}"
RELEASE_TITLE="${2:?Usage: publish-to-release.sh <tag> <title> <artifact-dir>}"
ARTIFACT_DIR="${3:?Usage: publish-to-release.sh <tag> <title> <artifact-dir>}"

ARTIFACT_DIR="$(cd "$ARTIFACT_DIR" && pwd)"
ZIP_FILE="$(ls "$ARTIFACT_DIR"/*.zip | head -1)"
CHANGELOG="$ARTIFACT_DIR/ChangeLog.txt"

if [ ! -f "$ZIP_FILE" ]; then
  echo "No zip file found in $ARTIFACT_DIR" >&2
  exit 1
fi

if [ ! -f "$CHANGELOG" ]; then
  echo "ChangeLog.txt not found in $ARTIFACT_DIR" >&2
  exit 1
fi

export GH_TOKEN="${GITHUB_TOKEN:?GITHUB_TOKEN is required}"

gh release create "$RELEASE_TAG" \
  --title "$RELEASE_TITLE" \
  --notes-file "$CHANGELOG" \
  "$ZIP_FILE" \
  "$CHANGELOG"

echo "Published release: $RELEASE_TAG"
