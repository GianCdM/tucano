#!/bin/sh
# Builds the .dmg and .zip for Apple Silicon and publishes them as a GitHub
# release, tagged with package.json's version. No Apple certificate: the app
# gets an ad-hoc signature, the least an Apple Silicon Mac runs. People install
# with install.sh (no Gatekeeper warning) or open the .dmg and allow it once in
# System Settings. --no-publish builds and stops, for testing.
set -e
cd "$(dirname "$0")/.."
VERSION=$(node -p "require('./package.json').version")
TAG="v$VERSION"
OUT="$HOME/Library/Caches/tucano/release"

if [ "$1" != "--no-publish" ]; then
  [ -z "$(git status --porcelain)" ] || { echo "There are uncommitted changes." >&2; exit 1; }
  gh release view "$TAG" >/dev/null 2>&1 && { echo "Release $TAG already exists: bump the version in package.json." >&2; exit 1; }
fi

npm run build
npx electron-builder --mac dmg zip --arm64 --publish never \
  --config.directories.output="$OUT" \
  --config.mac.identity=- \
  --config.artifactName='tucano-mac-${arch}.${ext}'

codesign --verify --deep --strict "$OUT/mac-arm64/Tucano.app"
echo "Signature ok. Files in $OUT:"
ls -lh "$OUT"/tucano-mac-arm64.*

[ "$1" = "--no-publish" ] && exit 0
git push origin HEAD
gh release create "$TAG" "$OUT/tucano-mac-arm64.dmg" "$OUT/tucano-mac-arm64.zip" install.sh \
  --target "$(git rev-parse HEAD)" --title "Tucano $VERSION" --notes-file docs/release-notes.md
