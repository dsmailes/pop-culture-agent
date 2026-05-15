#!/bin/sh
set -eu

REPO_RAW_URL="${POP_CULTURE_AGENT_RAW_URL:-https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main}"
INSTALL_DIR="${POP_CULTURE_AGENT_DIR:-pop-culture-agent}"
INCLUDE_LINE="@./${INSTALL_DIR}/AGENTS.md"
COPILOT_LINE="Refer to [Pop Culture Agent](../${INSTALL_DIR}/AGENTS.md) for agent progress-update style."

if [ -z "${POP_CULTURE_AGENT_ALLOW_SELF_INSTALL:-}" ] &&
  [ -f install.sh ] &&
  [ -f pop-culture-agent/AGENTS.snippet.md ] &&
  [ -f pop-culture-agent/quotes.json ] &&
  [ -f pop-culture-agent/config.strict.md ] &&
  [ -f pop-culture-agent/config.open.md ]; then
  echo "Pop Culture Agent: this looks like the Pop Culture Agent source repo." >&2
  echo "Run the installer from the target repo, or set POP_CULTURE_AGENT_ALLOW_SELF_INSTALL=1 to override." >&2
  exit 1
fi

can_prompt() {
  [ -z "${POP_CULTURE_AGENT_NONINTERACTIVE:-}" ] && [ -r /dev/tty ] && [ -w /dev/tty ]
}

prompt_mode() {
  if [ "${POP_CULTURE_AGENT_MODE+x}" = x ]; then
    printf '%s\n' "$POP_CULTURE_AGENT_MODE"
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
    echo "Pop Culture Agent: no interactive terminal detected; using strict mode." >&2
    printf '%s\n' "strict"
  fi
}

prompt_targets() {
  if [ "${POP_CULTURE_AGENT_TARGETS+x}" = x ]; then
    printf '%s\n' "$POP_CULTURE_AGENT_TARGETS"
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
    echo "Pop Culture Agent: no interactive terminal detected; using all bridge targets." >&2
    printf '%s\n' "agents,claude,gemini,copilot"
  fi
}

REQUESTED_MODE=$(prompt_mode)
TARGETS=$(prompt_targets)

case "$REQUESTED_MODE" in
  strict) MODE=strict ;;
  open|improvise) MODE=open ;;
  *)
    echo "Pop Culture Agent: MODE must be 'strict', 'open', or 'improvise'." >&2
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

echo "Pop Culture Agent installed in ${MODE} mode."
echo "Pop Culture Agent targets: ${TARGETS}."
