#!/bin/sh
set -eu

REPO_RAW_URL="${POP_CULTURE_AGENT_RAW_URL:-https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main}"
REQUESTED_SCOPE="${POP_CULTURE_AGENT_SCOPE:-}"
REQUESTED_UPDATE="${POP_CULTURE_AGENT_UPDATE:-}"
FAVORITES_PROVIDED=${POP_CULTURE_AGENT_FAVORITES+x}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo) REQUESTED_SCOPE=repo ;;
    --global) REQUESTED_SCOPE=global ;;
    --scope=repo) REQUESTED_SCOPE=repo ;;
    --scope=global) REQUESTED_SCOPE=global ;;
    --update) REQUESTED_UPDATE=1 ;;
    --help|-h)
      cat <<'EOF'
Usage: install.sh [--repo|--global] [--update]

Options:
  --repo      Install into the current repository (default).
  --global    Install into user-level agent instruction files.
  --update    Refresh installed stock prompt files.

Environment:
  POP_CULTURE_AGENT_SCOPE=repo|global
  POP_CULTURE_AGENT_FAVORITES="Scream, Metal Gear Solid, Alien"
  POP_CULTURE_AGENT_TARGETS=agents,claude,gemini,copilot
  POP_CULTURE_AGENT_UPDATE=1
  POP_CULTURE_AGENT_NONINTERACTIVE=1
  POP_CULTURE_AGENT_DIR=path/to/install
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
  [ -z "${POP_CULTURE_AGENT_NONINTERACTIVE:-}" ] &&
    ( : < /dev/tty > /dev/tty ) 2>/dev/null
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

prompt_favorites() {
  if [ "${POP_CULTURE_AGENT_FAVORITES+x}" = x ]; then
    printf '%s\n' "$POP_CULTURE_AGENT_FAVORITES"
    return
  fi

  if can_prompt; then
    {
      printf '\n'
      printf 'Favorite films, games, shows, or franchises:\n'
      printf '  Enter up to 3, comma-separated. Leave blank to skip.\n'
      printf 'Favorites: '
    } > /dev/tty
    IFS= read -r answer < /dev/tty || answer=
    printf '%s\n' "$answer"
  else
    printf '%s\n' ""
  fi
}

SCOPE=$(prompt_scope)
FAVORITES=$(prompt_favorites)
TARGETS=$(prompt_targets)

case "$REQUESTED_UPDATE" in
  ""|0|false|False|FALSE|no|No|NO) UPDATE=0 ;;
  *) UPDATE=1 ;;
esac

case "$SCOPE" in
  repo|global) ;;
  *)
    echo "Pop Culture Agent: SCOPE must be 'repo' or 'global'." >&2
    exit 1
    ;;
esac

if [ "$SCOPE" = repo ] &&
  [ -z "${POP_CULTURE_AGENT_ALLOW_SELF_INSTALL:-}" ] &&
  [ -f install.sh ] &&
  [ -f pop-culture-agent/AGENTS.snippet.md ] &&
  [ -f pop-culture-agent/config.open.md ]; then
  echo "Pop Culture Agent: this looks like the Pop Culture Agent source repo." >&2
  echo "Run the installer from the target repo, use --global, or set POP_CULTURE_AGENT_ALLOW_SELF_INSTALL=1 to override." >&2
  exit 1
fi

if [ "${POP_CULTURE_AGENT_DIR+x}" = x ]; then
  case "$POP_CULTURE_AGENT_DIR" in
    "")
      echo "Pop Culture Agent: POP_CULTURE_AGENT_DIR must not be empty." >&2
      exit 1
      ;;
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

case "$INSTALL_DIR" in
  /*)
    INCLUDE_LINE="@${INSTALL_DIR}/AGENTS.md"
    COPILOT_PATH="${INSTALL_DIR}/AGENTS.md"
    ;;
  *)
    INCLUDE_LINE="@./${INSTALL_DIR}/AGENTS.md"
    COPILOT_PATH="../${INSTALL_DIR}/AGENTS.md"
    ;;
esac

# Nested imports resolve relative to the installed AGENTS.md itself.
SNIPPET_LINE="@./AGENTS.snippet.md"
PREFERENCES_LINE="@./preferences.md"
CONFIG_LINE="@./config.open.md"
COPILOT_LINE="Refer to [Pop Culture Agent](${COPILOT_PATH}) for agent progress-update style."

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
download_tmp=
trap '[ -z "$download_tmp" ] || rm -f "$download_tmp"' 0
trap 'exit 1' HUP INT TERM

fetch_file() {
  download_tmp=$(mktemp "$INSTALL_DIR/.download.XXXXXX")
  fetch "$1" "$download_tmp"
}

install_file_once() {
  src=$1
  dest=$2

  if [ -e "$dest" ]; then
    echo "Pop Culture Agent: preserving existing $dest." >&2
    return
  fi

  fetch_file "$src"
  mv "$download_tmp" "$dest"
  download_tmp=
}

update_file_with_backup() {
  src=$1
  dest=$2
  fetch_file "$src"
  if [ -e "$dest" ]; then
    cp "$dest" "$dest.bak"
  fi
  mv "$download_tmp" "$dest"
  download_tmp=
}

install_or_update_file() {
  src=$1
  dest=$2

  if [ "$UPDATE" = 1 ]; then
    update_file_with_backup "$src" "$dest"
  else
    install_file_once "$src" "$dest"
  fi
}

write_agent_file() {
  dest=$1

  {
    printf '%s\n' 'Read and follow these instruction files. Paths are relative to this file.' ''
    printf '%s\n' "$SNIPPET_LINE" "$PREFERENCES_LINE" "$CONFIG_LINE"
  } > "$dest"
}

write_preferences_file() {
  dest=$1
  favorites=$2
  favorite_lines=$(printf '%s\n' "$favorites" | tr ',' '\n' | awk '
    { sub(/^[[:space:]]+/, ""); sub(/[[:space:]]+$/, "") }
    NF && count < 3 { print "- " $0; count++ }
  ')

  if [ -z "$favorite_lines" ]; then
    cat > "$dest" <<'EOF'
# Pop Culture Agent Preferences

No user-favorite sources are configured yet.

When favorites are configured during install, prefer short, recognizable
references from those sources when they fit the current reasoning state. If none
has a clean fit, choose another varied pop-culture reference or skip the quote.
EOF
    return
  fi

  {
    printf '%s\n' "# Pop Culture Agent Preferences"
    printf '\n'
    printf '%s\n' "Prefer short, recognizable references from these user-favorite sources when they fit the current reasoning state:"
    printf '\n'

    printf '%s\n' "$favorite_lines"

    printf '\n'
    printf '%s\n' "If none of these sources has a clean fit, choose another varied pop-culture reference or skip the quote."
  } > "$dest"
}

install_or_update_preferences_file() {
  dest=$1

  if [ -e "$dest" ]; then
    if [ "$UPDATE" = 1 ] && { [ "$FAVORITES_PROVIDED" = x ] || [ -n "$FAVORITES" ]; }; then
      cp "$dest" "$dest.bak"
      write_preferences_file "$dest" "$FAVORITES"
    else
      echo "Pop Culture Agent: preserving existing $dest." >&2
    fi
  else
    write_preferences_file "$dest" "$FAVORITES"
  fi
}

install_or_update_agent_file() {
  dest=$1

  if [ -e "$dest" ]; then
    if [ "$UPDATE" = 1 ]; then
      cp "$dest" "$dest.bak"
      write_agent_file "$dest"
    else
      echo "Pop Culture Agent: preserving existing $dest." >&2
    fi
  else
    write_agent_file "$dest"
  fi
}

install_or_update_file "$REPO_RAW_URL/pop-culture-agent/AGENTS.snippet.md" "$INSTALL_DIR/AGENTS.snippet.md"
install_or_update_preferences_file "$INSTALL_DIR/preferences.md"
install_or_update_file "$REPO_RAW_URL/pop-culture-agent/config.open.md" "$INSTALL_DIR/config.open.md"
install_or_update_agent_file "$INSTALL_DIR/AGENTS.md"

if [ "$UPDATE" = 1 ]; then
  echo "Pop Culture Agent: update mode refreshed stock files." >&2
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

echo "Pop Culture Agent scope: ${SCOPE}."
echo "Pop Culture Agent targets: ${TARGETS}."
