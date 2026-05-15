#!/bin/sh
set -eu

REPO_RAW_URL="${AGENT_QUOTEBOARD_RAW_URL:-https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main}"
INSTALL_DIR="${AGENT_QUOTEBOARD_DIR:-agent-quoteboard}"
MODE="${AGENT_QUOTEBOARD_MODE:-strict}"
INCLUDE_LINE="@./${INSTALL_DIR}/AGENTS.md"

case "$MODE" in
  strict|open) ;;
  *)
    echo "Agent Quoteboard: MODE must be 'strict' or 'open'." >&2
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
  echo "Agent Quoteboard: install requires curl or wget." >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR"

fetch "$REPO_RAW_URL/agent-quoteboard/AGENTS.snippet.md" "$INSTALL_DIR/AGENTS.snippet.md"
fetch "$REPO_RAW_URL/agent-quoteboard/quotes.json" "$INSTALL_DIR/quotes.json"
fetch "$REPO_RAW_URL/agent-quoteboard/config.strict.md" "$INSTALL_DIR/config.strict.md"
fetch "$REPO_RAW_URL/agent-quoteboard/config.open.md" "$INSTALL_DIR/config.open.md"

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

echo "Agent Quoteboard installed in ${MODE} mode."
echo "AGENTS.md includes ${INCLUDE_LINE}."
