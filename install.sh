#!/bin/sh
# Installs or updates Tucano:
#   curl -fsSL https://github.com/eduwxyz/tucano/releases/latest/download/install.sh | sh
# The app is signed and notarized by Apple, so it opens with no warning; the
# "from the internet" mark is cleared below all the same. TUCANO_ZIP points at another zip (a URL or
# a local file) and TUCANO_DEST another folder, for testing a build
# before it is released (then it doesn't open the app).
# Before its public release Tucano was called agent-desk: an old agent-desk.app
# is closed and replaced, and its data comes along the first time Tucano opens.
set -e
REPO=eduwxyz/tucano
ZIP="${TUCANO_ZIP:-https://github.com/$REPO/releases/latest/download/tucano-mac-arm64.zip}"

# Messages in Portuguese on a Mac set to Portuguese, in English otherwise.
case "${LANG:-}" in pt*) PT=1 ;; *) PT= ;; esac
say() { if [ -n "$PT" ]; then echo "$1"; else echo "$2"; fi; }
fail() { say "$1" "$2" >&2; exit 1; }

[ "$(uname -s)" = Darwin ] || fail "O Tucano é só pra macOS." "Tucano runs on macOS only."
[ "$(uname -m)" = arm64 ] || fail "Por enquanto o Tucano é só pra Macs com chip Apple (M1 em diante)." "For now Tucano needs a Mac with Apple silicon (M1 or later)."

DEST="${TUCANO_DEST:-/Applications}"
[ -w "$DEST" ] || [ -n "$TUCANO_DEST" ] || DEST="$HOME/Applications"
mkdir -p "$DEST"
APP="$DEST/Tucano.app"
OLD="$DEST/agent-desk.app"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
say "Baixando o Tucano…" "Downloading Tucano…"
case "$ZIP" in
  http*) curl -fL --progress-bar -o "$TMP/tucano.zip" "$ZIP" ;;
  *) cp "$ZIP" "$TMP/tucano.zip" ;;
esac
ditto -x -k "$TMP/tucano.zip" "$TMP/app"
[ -d "$TMP/app/Tucano.app" ] || fail "O arquivo baixado não tem o Tucano.app." "The download doesn't contain Tucano.app."

# Copying over a running app leaves it unable to quit normally: close it first.
running() { pgrep -f "$APP/Contents/MacOS/Tucano\$" >/dev/null || pgrep -f "$OLD/Contents/MacOS/agent-desk\$" >/dev/null; }
if running; then
  say "Fechando o app aberto…" "Closing the running app…"
  for name in Tucano agent-desk; do
    osascript -e 'with timeout of 20 seconds' -e "tell application \"$name\" to quit" -e 'end timeout' >/dev/null 2>&1 || true
  done
  for _ in $(seq 1 30); do running || break; sleep 1; done
  running && fail "O app não fechou. Feche com ⌘Q e rode de novo." "The app didn't close. Quit it with ⌘Q and run this again."
fi

rm -rf "$APP"
ditto "$TMP/app/Tucano.app" "$APP"
xattr -r -d com.apple.quarantine "$APP" >/dev/null 2>&1 || true
if [ -d "$OLD" ] && [ -z "$TUCANO_DEST" ]; then
  rm -rf "$OLD"
  osascript -e 'tell application "System Events" to delete login item "agent-desk"' >/dev/null 2>&1 || true
fi
say "Instalado em $APP" "Installed in $APP"
[ -n "$TUCANO_DEST" ] || open "$APP"
