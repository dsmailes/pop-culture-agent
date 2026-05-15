#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file_contains_line() {
  file=$1
  line=$2

  [ -f "$file" ] || fail "missing file: $file"
  grep -Fxq "$line" "$file" || fail "$file does not contain: $line"
}

assert_line_count() {
  file=$1
  line=$2
  expected=$3
  actual=$(grep -Fxc "$line" "$file" || true)

  [ "$actual" = "$expected" ] || fail "$file contains '$line' $actual times, expected $expected"
}

assert_file_contains_text() {
  file=$1
  text=$2

  [ -f "$file" ] || fail "missing file: $file"
  grep -Fq "$text" "$file" || fail "$file does not contain expected text: $text"
}

tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/pop-culture-agent-test.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT

cd "$tmpdir"
mkdir -p pop-culture-agent .github
printf '%s\n' "# Existing agents" "Keep this project rule." > AGENTS.md
printf '%s\n' "# Existing installed agent" "Keep this local mode." > pop-culture-agent/AGENTS.md
printf '%s\n' '{"custom":true}' > pop-culture-agent/quotes.json
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
assert_file_contains_text pop-culture-agent/quotes.json '"custom":true'

tmpdir_open=$(mktemp -d "${TMPDIR:-/tmp}/pop-culture-agent-test-open.XXXXXX")
tmpdir_improvise=$(mktemp -d "${TMPDIR:-/tmp}/pop-culture-agent-test-improvise.XXXXXX")
tmpdir_targets=$(mktemp -d "${TMPDIR:-/tmp}/pop-culture-agent-test-targets.XXXXXX")
tmpdir_global=$(mktemp -d "${TMPDIR:-/tmp}/pop-culture-agent-test-global.XXXXXX")
tmpdir_self=$(mktemp -d "${TMPDIR:-/tmp}/pop-culture-agent-test-self.XXXXXX")
trap 'rm -rf "$tmpdir" "$tmpdir_open" "$tmpdir_improvise" "$tmpdir_targets" "$tmpdir_global" "$tmpdir_self"' EXIT

cd "$tmpdir_open"
POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_MODE=open sh "$repo_root/install.sh" >/dev/null

assert_file_contains_line pop-culture-agent/AGENTS.md "@./pop-culture-agent/config.open.md"

cd "$tmpdir_improvise"
POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_MODE=improvise sh "$repo_root/install.sh" >/dev/null

assert_file_contains_line pop-culture-agent/AGENTS.md "@./pop-culture-agent/config.open.md"

cd "$tmpdir_targets"
POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_TARGETS=agents,claude sh "$repo_root/install.sh" >/dev/null

assert_file_contains_line AGENTS.md "@./pop-culture-agent/AGENTS.md"
assert_file_contains_line CLAUDE.md "@./pop-culture-agent/AGENTS.md"
[ ! -f GEMINI.md ] || fail "GEMINI.md should not be created for agents,claude targets"
[ ! -f .github/copilot-instructions.md ] || fail "copilot instructions should not be created for agents,claude targets"

cd "$tmpdir_global"
HOME="$tmpdir_global/home" POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_SCOPE=global POP_CULTURE_AGENT_TARGETS=agents,claude,gemini sh "$repo_root/install.sh" >/dev/null
HOME="$tmpdir_global/home" POP_CULTURE_AGENT_RAW_URL="file://$repo_root" POP_CULTURE_AGENT_SCOPE=global POP_CULTURE_AGENT_TARGETS=agents,claude,gemini sh "$repo_root/install.sh" >/dev/null

global_agent_dir="$tmpdir_global/home/.pop-culture-agent"
global_include_line="@$global_agent_dir/AGENTS.md"

assert_file_contains_line "$global_agent_dir/AGENTS.md" "@$global_agent_dir/AGENTS.snippet.md"
assert_file_contains_line "$global_agent_dir/AGENTS.md" "@$global_agent_dir/quotes.json"
assert_file_contains_line "$global_agent_dir/AGENTS.md" "@$global_agent_dir/config.strict.md"
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
cp "$repo_root/pop-culture-agent/quotes.json" "$tmpdir_self/pop-culture-agent/quotes.json"
cp "$repo_root/pop-culture-agent/config.strict.md" "$tmpdir_self/pop-culture-agent/config.strict.md"
cp "$repo_root/pop-culture-agent/config.open.md" "$tmpdir_self/pop-culture-agent/config.open.md"

cd "$tmpdir_self"
if POP_CULTURE_AGENT_RAW_URL="file://$tmpdir_self" POP_CULTURE_AGENT_NONINTERACTIVE=1 sh "$tmpdir_self/install.sh" >/dev/null 2>&1; then
  fail "installer should refuse to run from the Pop Culture Agent source tree"
fi

[ ! -f CLAUDE.md ] || fail "self-install should not create CLAUDE.md"
[ ! -f GEMINI.md ] || fail "self-install should not create GEMINI.md"
[ ! -f .github/copilot-instructions.md ] || fail "self-install should not create copilot instructions"

echo "install tests passed"
