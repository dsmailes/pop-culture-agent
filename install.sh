#!/bin/sh
set -eu

REPO_RAW_URL="${POP_CULTURE_AGENT_RAW_URL:-https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main}"
REQUESTED_SCOPE="${POP_CULTURE_AGENT_SCOPE:-}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo) REQUESTED_SCOPE=repo ;;
    --global) REQUESTED_SCOPE=global ;;
    --scope=repo) REQUESTED_SCOPE=repo ;;
    --scope=global) REQUESTED_SCOPE=global ;;
    --help|-h)
      cat <<'EOF'
Usage: install.sh [--repo|--global]

Options:
  --repo      Install into the current repository (default).
  --global    Install into user-level agent instruction files.

Environment:
  POP_CULTURE_AGENT_SCOPE=repo|global
  POP_CULTURE_AGENT_MODE=strict|open|improvise
  POP_CULTURE_AGENT_TARGETS=agents,claude,gemini,copilot
EOF
      exit 0
      ;;
    *)
      echo "Pop Culture Agent: unknown option '$1'." >&2
      exit 1
      ;;
  esac
  shift
done

can_prompt() {
  [ -z "${POP_CULTURE_AGENT_NONINTERACTIVE:-}" ] && [ -r /dev/tty ] && [ -w /dev/tty ]
}

prompt_scope() {
  if [ -n "$REQUESTED_SCOPE" ]; then
    printf '%s\n' "$REQUESTED_SCOPE"
    return
  fi

  if can_prompt; then
    {
      printf '\n'
      printf 'Pop Culture Agent install scope:\n'
      printf '  1) Repo - install into the current repository (default)\n'
      printf '  2) Global - install into user-level agent instruction files\n'
      printf 'Choose scope [1]: '
    } > /dev/tty
    IFS= read -r answer < /dev/tty || answer=

    case "$answer" in
      2|g|G|global|Global) printf '%s\n' "global" ;;
      *) printf '%s\n' "repo" ;;
    esac
  else
    echo "Pop Culture Agent: no interactive terminal detected; using repo scope." >&2
    printf '%s\n' "repo"
  fi
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
      if [ "$SCOPE" = global ]; then
        printf '  1) All global: Codex, Claude, Gemini (default)\n'
      else
        printf '  1) All: AGENTS.md, CLAUDE.md, GEMINI.md, Copilot (default)\n'
      fi
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
        if [ -n "$custom_targets" ]; then
          printf '%s\n' "$custom_targets"
        elif [ "$SCOPE" = global ]; then
          printf '%s\n' "agents,claude,gemini"
        else
          printf '%s\n' "agents,claude,gemini,copilot"
        fi
        ;;
      *)
        if [ "$SCOPE" = global ]; then
          printf '%s\n' "agents,claude,gemini"
        else
          printf '%s\n' "agents,claude,gemini,copilot"
        fi
        ;;
    esac
  else
    if [ "$SCOPE" = global ]; then
      echo "Pop Culture Agent: no interactive terminal detected; using all global bridge targets." >&2
      printf '%s\n' "agents,claude,gemini"
    else
      echo "Pop Culture Agent: no interactive terminal detected; using all bridge targets." >&2
      printf '%s\n' "agents,claude,gemini,copilot"
    fi
  fi
}

SCOPE=$(prompt_scope)
REQUESTED_MODE=$(prompt_mode)
TARGETS=$(prompt_targets)

case "$SCOPE" in
  repo|global) ;;
  *)
    echo "Pop Culture Agent: SCOPE must be 'repo' or 'global'." >&2
    exit 1
    ;;
esac

case "$REQUESTED_MODE" in
  strict) MODE=strict ;;
  open|improvise) MODE=open ;;
  *)
    echo "Pop Culture Agent: MODE must be 'strict', 'open', or 'improvise'." >&2
    exit 1
    ;;
esac

if [ "$SCOPE" = repo ] &&
  [ -z "${POP_CULTURE_AGENT_ALLOW_SELF_INSTALL:-}" ] &&
  [ -f install.sh ] &&
  [ -f pop-culture-agent/AGENTS.snippet.md ] &&
  [ -f pop-culture-agent/quotes.json ] &&
  [ -f pop-culture-agent/config.strict.md ] &&
  [ -f pop-culture-agent/config.open.md ]; then
  echo "Pop Culture Agent: this looks like the Pop Culture Agent source repo." >&2
  echo "Run the installer from the target repo, use --global, or set POP_CULTURE_AGENT_ALLOW_SELF_INSTALL=1 to override." >&2
  exit 1
fi

if [ "${POP_CULTURE_AGENT_DIR+x}" = x ]; then
  case "$POP_CULTURE_AGENT_DIR" in
    /*) INSTALL_DIR=$POP_CULTURE_AGENT_DIR ;;
    *)
      if [ "$SCOPE" = global ]; then
        INSTALL_DIR="${HOME:?}/$POP_CULTURE_AGENT_DIR"
      else
        INSTALL_DIR=$POP_CULTURE_AGENT_DIR
      fi
      ;;
  esac
elif [ "$SCOPE" = global ]; then
  INSTALL_DIR="${HOME:?}/.pop-culture-agent"
else
  INSTALL_DIR="pop-culture-agent"
fi

if [ "$SCOPE" = global ]; then
  INCLUDE_LINE="@${INSTALL_DIR}/AGENTS.md"
  SNIPPET_LINE="@${INSTALL_DIR}/AGENTS.snippet.md"
  QUOTES_LINE="@${INSTALL_DIR}/quotes.json"
  CONFIG_LINE="@${INSTALL_DIR}/config.${MODE}.md"
else
  INCLUDE_LINE="@./${INSTALL_DIR}/AGENTS.md"
  SNIPPET_LINE="@./${INSTALL_DIR}/AGENTS.snippet.md"
  QUOTES_LINE="@./${INSTALL_DIR}/quotes.json"
  CONFIG_LINE="@./${INSTALL_DIR}/config.${MODE}.md"
fi

COPILOT_LINE="Refer to [Pop Culture Agent](../${INSTALL_DIR}/AGENTS.md) for agent progress-update style."

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

install_file_once() {
  src=$1
  dest=$2

  if [ -e "$dest" ]; then
    echo "Pop Culture Agent: preserving existing $dest." >&2
    return
  fi

  fetch "$src" "$dest"
}

install_file_once "$REPO_RAW_URL/pop-culture-agent/AGENTS.snippet.md" "$INSTALL_DIR/AGENTS.snippet.md"
install_file_once "$REPO_RAW_URL/pop-culture-agent/quotes.json" "$INSTALL_DIR/quotes.json"
install_file_once "$REPO_RAW_URL/pop-culture-agent/config.strict.md" "$INSTALL_DIR/config.strict.md"
install_file_once "$REPO_RAW_URL/pop-culture-agent/config.open.md" "$INSTALL_DIR/config.open.md"

if [ -e "$INSTALL_DIR/AGENTS.md" ]; then
  echo "Pop Culture Agent: preserving existing $INSTALL_DIR/AGENTS.md." >&2
else
  {
    echo "$SNIPPET_LINE"
    echo "$QUOTES_LINE"
    echo "$CONFIG_LINE"
  } > "$INSTALL_DIR/AGENTS.md"
fi

has_target() {
  case ",$TARGETS," in
    *",$1,"*) return 0 ;;
    *) return 1 ;;
  esac
}

append_line_once() {
  file=$1
  line=$2
  dir=${file%/*}

  if [ "$dir" != "$file" ]; then
    mkdir -p "$dir"
  fi

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
  if [ "$SCOPE" = global ]; then
    append_line_once "${CODEX_HOME:-${HOME:?}/.codex}/AGENTS.md" "$INCLUDE_LINE"
  else
    append_line_once AGENTS.md "$INCLUDE_LINE"
  fi
fi

if has_target claude; then
  if [ "$SCOPE" = global ]; then
    append_line_once "${CLAUDE_CONFIG_DIR:-${HOME:?}/.claude}/CLAUDE.md" "$INCLUDE_LINE"
  else
    append_line_once CLAUDE.md "$INCLUDE_LINE"
  fi
fi

if has_target gemini; then
  if [ "$SCOPE" = global ]; then
    append_line_once "${GEMINI_CONFIG_DIR:-${HOME:?}/.gemini}/GEMINI.md" "$INCLUDE_LINE"
  else
    append_line_once GEMINI.md "$INCLUDE_LINE"
  fi
fi

if has_target copilot; then
  if [ "$SCOPE" = global ]; then
    echo "Pop Culture Agent: skipping copilot target for global scope; Copilot uses repo-level .github/copilot-instructions.md." >&2
  else
    mkdir -p .github
    append_line_once .github/copilot-instructions.md "$COPILOT_LINE"
  fi
fi

echo "Pop Culture Agent installed in ${MODE} mode."
echo "Pop Culture Agent scope: ${SCOPE}."
echo "Pop Culture Agent targets: ${TARGETS}."
