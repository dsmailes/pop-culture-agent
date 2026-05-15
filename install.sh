#!/bin/sh
set -eu

REPO_RAW_URL="${AGENT_QUOTEBOARD_RAW_URL:-https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main}"
INSTALL_DIR="${AGENT_QUOTEBOARD_DIR:-agent-quoteboard}"
INCLUDE_LINE="@./${INSTALL_DIR}/AGENTS.md"
COPILOT_LINE="Refer to [Agent Quoteboard](../${INSTALL_DIR}/AGENTS.md) for agent progress-update style."

if [ -z "${AGENT_QUOTEBOARD_ALLOW_SELF_INSTALL:-}" ] &&
  [ -f install.sh ] &&
  [ -f agent-quoteboard/AGENTS.snippet.md ] &&
  [ -f agent-quoteboard/quotes.json ] &&
  [ -f agent-quoteboard/config.strict.md ] &&
  [ -f agent-quoteboard/config.open.md ]; then
  echo "Agent Quoteboard: this looks like the Pop Culture Agent source repo." >&2
  echo "Run the installer from the target repo, or set AGENT_QUOTEBOARD_ALLOW_SELF_INSTALL=1 to override." >&2
  exit 1
fi

can_prompt() {
  [ -z "${AGENT_QUOTEBOARD_NONINTERACTIVE:-}" ] && [ -r /dev/tty ] && [ -w /dev/tty ]
}

prompt_mode() {
  if [ "${AGENT_QUOTEBOARD_MODE+x}" = x ]; then
    printf '%s\n' "$AGENT_QUOTEBOARD_MODE"
    return
  fi

  if can_prompt; then
    {
      printf '\n'
      printf 'Pop Culture Agent mode:\n'
      printf '  1) Strict - use only the quote bank (default)\n'
      printf '  2) Improvise - allow short fallback lines\n'
      printf 'Choose mode [1]: '
    } > /dev/tty
    IFS= read -r answer < /dev/tty || answer=

    case "$answer" in
      2|i|I|improvise|Improvise) printf '%s\n' "improvise" ;;
      *) printf '%s\n' "strict" ;;
    esac
  else
    echo "Agent Quoteboard: no interactive terminal detected; using strict mode." >&2
    printf '%s\n' "strict"
  fi
}

prompt_targets() {
  if [ "${AGENT_QUOTEBOARD_TARGETS+x}" = x ]; then
    printf '%s\n' "$AGENT_QUOTEBOARD_TARGETS"
    return
  fi

  if can_prompt; then
    {
      printf '\n'
      printf 'Agent bridge files:\n'
      printf '  1) All: AGENTS.md, CLAUDE.md, GEMINI.md, Copilot (default)\n'
      printf '  2) AGENTS.md only\n'
      printf '  3) AGENTS.md + CLAUDE.md\n'
      printf '  4) Custom comma list (agents,claude,gemini,copilot)\n'
      printf 'Choose targets [1]: '
    } > /dev/tty
    IFS= read -r answer < /dev/tty || answer=

    case "$answer" in
      2) printf '%s\n' "agents" ;;
      3) printf '%s\n' "agents,claude" ;;
      4)
        printf 'Custom targets: ' > /dev/tty
        IFS= read -r custom_targets < /dev/tty || custom_targets=
        printf '%s\n' "${custom_targets:-agents,claude,gemini,copilot}"
        ;;
      *) printf '%s\n' "agents,claude,gemini,copilot" ;;
    esac
  else
    echo "Agent Quoteboard: no interactive terminal detected; using all bridge targets." >&2
    printf '%s\n' "agents,claude,gemini,copilot"
  fi
}

REQUESTED_MODE=$(prompt_mode)
TARGETS=$(prompt_targets)

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
