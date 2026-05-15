#!/bin/sh
set -eu

REPO_RAW_URL="${AGENT_QUOTEBOARD_RAW_URL:-https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main}"
INSTALL_DIR="${AGENT_QUOTEBOARD_DIR:-agent-quoteboard}"
REQUESTED_MODE="${AGENT_QUOTEBOARD_MODE:-strict}"
TARGETS="${AGENT_QUOTEBOARD_TARGETS:-agents,claude,gemini,copilot}"
INCLUDE_LINE="@./${INSTALL_DIR}/AGENTS.md"
COPILOT_LINE="Refer to [Agent Quoteboard](../${INSTALL_DIR}/AGENTS.md) for agent progress-update style."

case "$REQUESTED_MODE" in
  strict) MODE=strict ;;
  open|improvise) MODE=open ;;
  *)
    echo "Agent Quoteboard: MODE must be 'strict', 'open', or 'improvise'." >&2
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

has_target() {
  case ",$TARGETS," in
    *",$1,"*) return 0 ;;
    *) return 1 ;;
  esac
}

append_line_once() {
  file=$1
  line=$2

  if [ ! -f "$file" ]; then
    printf '%s\n' "$line" > "$file"
  elif ! grep -Fxq "$line" "$file"; then
    {
      printf '\n'
      printf '%s\n' "$line"
    } >> "$file"
  fi
}

if has_target agents; then
  append_line_once AGENTS.md "$INCLUDE_LINE"
fi

if has_target claude; then
  append_line_once CLAUDE.md "$INCLUDE_LINE"
fi

if has_target gemini; then
  append_line_once GEMINI.md "$INCLUDE_LINE"
fi

if has_target copilot; then
  mkdir -p .github
  append_line_once .github/copilot-instructions.md "$COPILOT_LINE"
fi

echo "Agent Quoteboard installed in ${MODE} mode."
echo "Agent Quoteboard targets: ${TARGETS}."
