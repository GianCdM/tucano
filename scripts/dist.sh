#!/bin/sh
# Builds Tucano.app for this Mac (no .dmg, not notarized). Signed with the
# keychain's Developer ID certificate, the one releases use, or else an Apple
# Development one (macOS then delivers notifications and remembers Keychain
# permissions across builds); ad-hoc otherwise. TUCANO_SIGN_IDENTITY picks
# another identity.
set -e
cd "$(dirname "$0")/.."
ids=$(security find-identity -v -p codesigning 2>/dev/null)
IDENTITY="${TUCANO_SIGN_IDENTITY:-$(echo "$ids" | awk '/Developer ID Application/ { print $2; exit }')}"
IDENTITY="${IDENTITY:-$(echo "$ids" | awk '/Apple Development/ { print $2; exit }')}"
npm run build
npx electron-builder --mac --dir \
  --config.directories.output="$HOME/Library/Caches/tucano/dist" \
  --config.mac.identity="${IDENTITY:--}"
