#!/bin/sh
set -eu

# Keep tests independent of the caller's installation settings and terminal.
unset POP_CULTURE_AGENT_RAW_URL POP_CULTURE_AGENT_SCOPE POP_CULTURE_AGENT_TARGETS
unset POP_CULTURE_AGENT_FAVORITES POP_CULTURE_AGENT_UPDATE POP_CULTURE_AGENT_DIR
unset POP_CULTURE_AGENT_ALLOW_SELF_INSTALL CODEX_HOME CLAUDE_CONFIG_DIR GEMINI_CONFIG_DIR
export POP_CULTURE_AGENT_NONINTERACTIVE=1

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file_contains_line() {
  file=$1
  line=$2

  [ -f "$file" ] || fail "missing file: $file"
  grep -Fxq -- "$line" "$file" || fail "$file does not contain: $line"
}

assert_line_count() {
  file=$1
  line=$2
  expected=$3
  actual=$(grep -Fxc -- "$line" "$file" || true)

  [ "$actual" = "$expected" ] || fail "$file contains '$line' $actual times, expected $expected"
}

assert_file_contains_text() {
  file=$1
  text=$2

  [ -f "$file" ] || fail "missing file: $file"
  grep -Fq -- "$text" "$file" || fail "$file does not contain expected text: $text"
}

tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/pop-culture-agent-test.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT

cd "$tmpdir"
mkdir -p pop-culture-agent .github
printf '%s\n' "# Existing agents" "Keep this project rule." > AGENTS.md
printf '%s\n' "# Existing installed agent" "Keep this local mode." > pop-culture-agent/AGENTS.md
printf '%s\n' "# Existing Copilot instructions" > .github/copilot-instructions.md

POP_CULTURE_AGENT_RAW_URL="file://$repo_root" sh "$repo_root/install.sh" >/dev/null
POP_CULTURE_AGENT_RAW_URL="file://$repo_root" sh "$repo_root/install.sh" >/dev/null

assert_file_contains_line AGENTS.md "@./pop-culture-agent/AGENTS.md"
assert_file_contains_line CLAUDE.md "@./pop-culture-agent/AGENTS.md"
assert_file_contains_line GEMINI.md "@./pop-culture-agent/AGENTS.md"
assert_file_contains_line .github/copilot-instructions.md "Refer to [Pop Culture Agent](../pop-culture-agent/AGENTS.md) for agent progress-update style."

assert_line_count AGENTS.md "@./pop-culture-agent/AGENTS.md" 1
assert_line_count CLAUDE.md "@./pop-culture-agent/AGENTS.md" 1
assert_line_count GEMINI.md "@./pop-culture-agent/AGENTS.md" 1
assert_line_count .github/copilot-instructions.md "Refer to [Pop Culture Agent](../pop-culture-agent/AGENTS.md) for agent progress-update style." 1

assert_file_contains_text AGENTS.md "Keep this project rule."
assert_file_contains_text .github/copilot-instructions.md "# Existing Copilot instructions"
assert_file_contains_text pop-culture-agent/AGENTS.md "Keep this local mode."
cmp pop-culture-agent/preferences.md "$repo_root/pop-culture-agent/preferences.md" || fail "empty preferences differ from bundled default"

tmpdir_targets="$tmpdir/targets"
mkdir -p "$tmpdir_targets"
tmpdir_favorites="$tmpdir/favorites"
mkdir -p "$tmpdir_favorites"
tmpdir_update="$tmpdir/update"
mkdir -p "$tmpdir_update"
tmpdir_global="$tmpdir/global"
mkdir -p "$tmpdir_global"
tmpdir_self="$tmpdir/self"
mkdir -p "$tmpdir_self"


cd "$tmpdir_targets"
POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_TARGETS=agents,claude sh "$repo_root/install.sh" >/dev/null

assert_file_contains_line AGENTS.md "@./pop-culture-agent/AGENTS.md"
assert_file_contains_line CLAUDE.md "@./pop-culture-agent/AGENTS.md"
[ ! -f GEMINI.md ] || fail "GEMINI.md should not be created for agents,claude targets"
[ ! -f .github/copilot-instructions.md ] || fail "copilot instructions should not be created for agents,claude targets"

cd "$tmpdir_favorites"
POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_FAVORITES="Scream, Metal Gear Solid, Alien, Extra" sh "$repo_root/install.sh" >/dev/null

assert_file_contains_line pop-culture-agent/AGENTS.md "@./AGENTS.snippet.md"
assert_file_contains_line pop-culture-agent/AGENTS.md "@./preferences.md"
assert_file_contains_line pop-culture-agent/AGENTS.md "@./config.open.md"
assert_file_contains_text pop-culture-agent/preferences.md "- Scream"
assert_file_contains_text pop-culture-agent/preferences.md "- Metal Gear Solid"
assert_file_contains_text pop-culture-agent/preferences.md "- Alien"
if grep -Fq -- "- Extra" pop-culture-agent/preferences.md; then
  fail "preferences should only include the first three favorites"
fi

cd "$tmpdir_update"
mkdir -p pop-culture-agent
printf '%s\n' "@./pop-culture-agent/old-config.md" > pop-culture-agent/AGENTS.md
printf '%s\n' "old snippet" > pop-culture-agent/AGENTS.snippet.md
printf '%s\n' "old preferences" > pop-culture-agent/preferences.md
printf '%s\n' "old open config" > pop-culture-agent/config.open.md

POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_UPDATE=1 sh "$repo_root/install.sh" >/dev/null

assert_file_contains_line pop-culture-agent/AGENTS.md "@./AGENTS.snippet.md"
assert_file_contains_line pop-culture-agent/AGENTS.md "@./preferences.md"
assert_file_contains_line pop-culture-agent/AGENTS.md "@./config.open.md"
assert_file_contains_text pop-culture-agent/AGENTS.snippet.md "Default to **moderate**."
assert_file_contains_text pop-culture-agent/config.open.md "open improvisation"
assert_file_contains_text pop-culture-agent/preferences.md "old preferences"
assert_file_contains_text pop-culture-agent/AGENTS.md.bak "@./pop-culture-agent/old-config.md"
assert_file_contains_text pop-culture-agent/AGENTS.snippet.md.bak "old snippet"

cd "$tmpdir_global"
POP_CULTURE_AGENT_DIR="$tmpdir_global/home/.pop-culture-agent" CODEX_HOME="$tmpdir_global/home/.codex" CLAUDE_CONFIG_DIR="$tmpdir_global/home/.claude" GEMINI_CONFIG_DIR="$tmpdir_global/home/.gemini" POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_SCOPE=global POP_CULTURE_AGENT_TARGETS=agents,claude,gemini sh "$repo_root/install.sh" >/dev/null
POP_CULTURE_AGENT_DIR="$tmpdir_global/home/.pop-culture-agent" CODEX_HOME="$tmpdir_global/home/.codex" CLAUDE_CONFIG_DIR="$tmpdir_global/home/.claude" GEMINI_CONFIG_DIR="$tmpdir_global/home/.gemini" POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_SCOPE=global POP_CULTURE_AGENT_TARGETS=agents,claude,gemini sh "$repo_root/install.sh" >/dev/null

global_agent_dir="$tmpdir_global/home/.pop-culture-agent"
global_include_line="@$global_agent_dir/AGENTS.md"

assert_file_contains_line "$global_agent_dir/AGENTS.md" "@./AGENTS.snippet.md"
assert_file_contains_line "$global_agent_dir/AGENTS.md" "@./preferences.md"
assert_file_contains_line "$global_agent_dir/AGENTS.md" "@./config.open.md"
assert_file_contains_line "$tmpdir_global/home/.codex/AGENTS.md" "$global_include_line"
assert_file_contains_line "$tmpdir_global/home/.claude/CLAUDE.md" "$global_include_line"
assert_file_contains_line "$tmpdir_global/home/.gemini/GEMINI.md" "$global_include_line"
assert_line_count "$tmpdir_global/home/.codex/AGENTS.md" "$global_include_line" 1
assert_line_count "$tmpdir_global/home/.claude/CLAUDE.md" "$global_include_line" 1
assert_line_count "$tmpdir_global/home/.gemini/GEMINI.md" "$global_include_line" 1
[ ! -f AGENTS.md ] || fail "global install should not create repo AGENTS.md"

mkdir -p "$tmpdir_self/pop-culture-agent"
cp "$repo_root/install.sh" "$tmpdir_self/install.sh"
cp "$repo_root/pop-culture-agent/AGENTS.snippet.md" "$tmpdir_self/pop-culture-agent/AGENTS.snippet.md"
printf '%s\n' "# Pop Culture Agent Preferences" > "$tmpdir_self/pop-culture-agent/preferences.md"
cp "$repo_root/pop-culture-agent/config.open.md" "$tmpdir_self/pop-culture-agent/config.open.md"

cd "$tmpdir_self"
if POP_CULTURE_AGENT_RAW_URL="file://$tmpdir_self" POP_CULTURE_AGENT_NONINTERACTIVE=1 sh "$tmpdir_self/install.sh" >/dev/null 2>&1; then
  fail "installer should refuse to run from the Pop Culture Agent source tree"
fi

[ ! -f CLAUDE.md ] || fail "self-install should not create CLAUDE.md"
[ ! -f GEMINI.md ] || fail "self-install should not create GEMINI.md"
[ ! -f .github/copilot-instructions.md ] || fail "self-install should not create copilot instructions"

# Follow nested imports from the importing file, as Claude and Gemini do.
assert_imports_resolve() {
  in_code_block=0
  while IFS= read -r import_line; do
    case "$import_line" in
      '```'*) in_code_block=$((1 - in_code_block)); continue ;;
    esac
    [ "$in_code_block" = 0 ] || continue
    case "$import_line" in
      @/*) import_path=${import_line#@} ;;
      @*) import_path="$(dirname "$1")/${import_line#@}" ;;
      *) continue ;;
    esac
    [ -f "$import_path" ] || fail "unresolved import in $1: $import_line"
    (assert_imports_resolve "$import_path")
  done < "$1"
}

assert_imports_resolve "$tmpdir_favorites/CLAUDE.md"
assert_imports_resolve "$tmpdir_favorites/GEMINI.md"
assert_imports_resolve "$tmpdir_global/home/.claude/CLAUDE.md"
assert_imports_resolve "$repo_root/AGENTS.md"
assert_imports_resolve "$repo_root/pop-culture-agent/AGENTS.md"

# Explicit favorites update with a backup, including clearing them to defaults.
cd "$tmpdir_favorites"
POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_FAVORITES="  Alien , , Portal  " sh "$repo_root/install.sh" --update >/dev/null
assert_file_contains_text pop-culture-agent/preferences.md.bak "- Scream"
assert_file_contains_line pop-culture-agent/preferences.md "- Portal"
POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_FAVORITES='' sh "$repo_root/install.sh" --update >/dev/null
assert_file_contains_text pop-culture-agent/preferences.md.bak "- Portal"
cmp pop-culture-agent/preferences.md "$repo_root/pop-culture-agent/preferences.md" || fail "clearing favorites did not restore defaults"

# Both relative and absolute custom paths must resolve from every bridge.
mkdir -p "$tmpdir/custom" "$tmpdir/absolute" "$tmpdir/empty-dir"
cd "$tmpdir/custom"
POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_DIR=prompts/culture sh "$repo_root/install.sh" --repo >/dev/null
assert_file_contains_line AGENTS.md "@./prompts/culture/AGENTS.md"
assert_imports_resolve CLAUDE.md
assert_file_contains_line .github/copilot-instructions.md "Refer to [Pop Culture Agent](../prompts/culture/AGENTS.md) for agent progress-update style."
cd "$tmpdir/absolute"
POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_DIR="$tmpdir/shared" sh "$repo_root/install.sh" --repo >/dev/null
assert_file_contains_line AGENTS.md "@$tmpdir/shared/AGENTS.md"
assert_imports_resolve CLAUDE.md
assert_file_contains_line .github/copilot-instructions.md "Refer to [Pop Culture Agent]($tmpdir/shared/AGENTS.md) for agent progress-update style."
cd "$tmpdir/empty-dir"
if POP_CULTURE_AGENT_DIR='' sh "$repo_root/install.sh" --repo >/dev/null 2>&1; then
  fail "an empty install directory should be rejected"
fi
[ ! -f AGENTS.md ] || fail "invalid directory should not create bridge files"

# Simulate a download that writes partial content and then fails.
mkdir -p "$tmpdir/fake-bin" "$tmpdir/failed-download"
cat > "$tmpdir/fake-bin/curl" <<'EOF'
#!/bin/sh
printf '%s\n' 'partial download' > "$4"
exit 22
EOF
chmod +x "$tmpdir/fake-bin/curl"
cd "$tmpdir/failed-download"
if PATH="$tmpdir/fake-bin:$PATH" sh "$repo_root/install.sh" --repo >/dev/null 2>&1; then
  fail "a failed download should fail installation"
fi
[ ! -f pop-culture-agent/AGENTS.snippet.md ] || fail "partial download became an installed file"
[ ! -f AGENTS.md ] || fail "failed installation created a bridge"
for download in pop-culture-agent/.download.*; do
  [ ! -e "$download" ] || fail "failed download left a temporary file"
done
POP_CULTURE_AGENT_RAW_URL="file://$repo_root" sh "$repo_root/install.sh" --repo >/dev/null
cp pop-culture-agent/AGENTS.snippet.md expected-snippet.md
if PATH="$tmpdir/fake-bin:$PATH" sh "$repo_root/install.sh" --repo --update >/dev/null 2>&1; then
  fail "a failed download should fail update"
fi
cmp pop-culture-agent/AGENTS.snippet.md expected-snippet.md || fail "failed update replaced installed content"
for download in pop-culture-agent/.download.*; do
  [ ! -e "$download" ] || fail "failed update left a temporary file"
done

sh "$repo_root/install.sh" --help >/dev/null
if sh "$repo_root/install.sh" --unknown >/dev/null 2>&1; then
  fail "unknown options should fail"
fi

echo "install tests passed"
