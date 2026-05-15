#!/bin/sh
set -eu

REPO_RAW_URL="${POP_CULTURE_AGENT_RAW_URL:-https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main}"
INSTALL_DIR="${POP_CULTURE_AGENT_DIR:-pop-culture-agent}"
MODE="${POP_CULTURE_AGENT_MODE:-strict}"
INCLUDE_LINE="@./${INSTALL_DIR}/AGENTS.md"

case "$MODE" in
  strict|open) ;;
  *)
    echo "Pop Culture Agent: MODE must be 'strict' or 'open'." >&2
    exit 1
    ;;
esac

if command -v curl >/dev/null 2>&1; then
  fetch() {
    curl -fsSL "$1" -o "$2"
  }
elif command -v wget >/dev/null 2>&1; then
  fetch() {
    wget -qO "$2" "$1"
  }
else
  echo "Pop Culture Agent: install requires curl or wget." >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR"

fetch "$REPO_RAW_URL/pop-culture-agent/AGENTS.snippet.md" "$INSTALL_DIR/AGENTS.snippet.md"
fetch "$REPO_RAW_URL/pop-culture-agent/quotes.json" "$INSTALL_DIR/quotes.json"
fetch "$REPO_RAW_URL/pop-culture-agent/config.strict.md" "$INSTALL_DIR/config.strict.md"
fetch "$REPO_RAW_URL/pop-culture-agent/config.open.md" "$INSTALL_DIR/config.open.md"

{
  echo "@./${INSTALL_DIR}/AGENTS.snippet.md"
  echo "@./${INSTALL_DIR}/quotes.json"
  echo "@./${INSTALL_DIR}/config.${MODE}.md"
} > "$INSTALL_DIR/AGENTS.md"

if [ ! -f AGENTS.md ]; then
  printf '%s\n' "$INCLUDE_LINE" > AGENTS.md
elif ! grep -Fxq "$INCLUDE_LINE" AGENTS.md; then
  {
    printf '\n'
    printf '%s\n' "$INCLUDE_LINE"
  } >> AGENTS.md
fi

echo "Pop Culture Agent installed in ${MODE} mode."
echo "AGENTS.md includes ${INCLUDE_LINE}."
