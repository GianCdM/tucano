#!/bin/sh
# Builds Tucano.app for this Mac (no .dmg). Signed with an Apple Development
# certificate when the keychain has one (macOS then delivers notifications and
# remembers Keychain permissions across builds); ad-hoc otherwise.
# TUCANO_SIGN_IDENTITY picks another identity.
set -e
cd "$(dirname "$0")/.."
IDENTITY="${TUCANO_SIGN_IDENTITY:-$(security find-identity -v -p codesigning 2>/dev/null | awk '/Apple Development/ { print $2; exit }')}"
npm run build
npx electron-builder --mac --dir \
  --config.directories.output="$HOME/Library/Caches/tucano/dist" \
  --config.mac.identity="${IDENTITY:--}"
