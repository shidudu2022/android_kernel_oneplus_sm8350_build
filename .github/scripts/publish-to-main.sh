#!/usr/bin/env bash
set -euo pipefail

RELEASE_DIR="${1:?Usage: publish-to-main.sh <release-dir>}"
ARTIFACT_DIR="${2:?Usage: publish-to-main.sh <release-dir> <artifact-dir>}"

REPO_URL="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"

if git ls-remote --heads "$REPO_URL" main | grep -q main; then
  git clone --depth 1 --branch main "$REPO_URL" "$WORK_DIR/repo"
else
  git -C "$WORK_DIR" init repo
  cd "$WORK_DIR/repo"
  git remote add origin "$REPO_URL"
  cat > README.md <<'EOF'
# Kernel Releases

Prebuilt kernel images for OnePlus SM8350 (lemonade / lemonadep).
EOF
  git add README.md
  git commit -m "init: release branch"
  git branch -M main
  git push -u origin main
  cd -
fi

cd "$WORK_DIR/repo"
mkdir -p "$RELEASE_DIR"
cp "$ARTIFACT_DIR"/*.zip "$RELEASE_DIR/"
cp "$ARTIFACT_DIR"/ChangeLog.txt "$RELEASE_DIR/"
git add "$RELEASE_DIR"
git commit -m "release: ${RELEASE_DIR} $(date -u '+%Y%m%d-%H%M')"
git push origin main
