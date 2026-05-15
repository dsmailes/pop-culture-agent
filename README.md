# Pop Culture Agent

Pop Culture Agent is a prompt-only add-on for making coding agent progress
updates a little more characterful. It installs pop-culture-style progress
instructions into a target repository so compatible agents can replace bland
transition phrases with occasional short, bold lines while keeping technical
updates clear.

It is intentionally small:

- no package manager
- no runtime code
- no dependencies
- no build step

## Install

Run this from the root of the repo where you want Pop Culture Agent installed:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh
```

When run in a terminal, the installer asks you to choose:

- repo or global install scope
- improvise or strict mode
- which agent bridge files to create

Press Enter for the recommended defaults: repo scope, improvise mode, and all
supported repo bridge files.

To make the scope explicit in a one-line install, pass installer arguments with
`sh -s --`:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh -s -- --repo
```

For a global install:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh -s -- --global
```

If you do not want extra bridge files such as `CLAUDE.md`, `GEMINI.md`, or
`.github/copilot-instructions.md`, choose `AGENTS.md only` at the prompt.

In repo scope, the installer downloads `pop-culture-agent/`, writes the
selected quote config, and adds small bridge instructions for common coding
agents:

- `AGENTS.md` for Codex-style and other `AGENTS.md` readers
- `CLAUDE.md` for Claude Code
- `GEMINI.md` for Gemini CLI
- `.github/copilot-instructions.md` for GitHub Copilot

For `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md`, the bridge line is:

```md
@./pop-culture-agent/AGENTS.md
```

For Copilot, the bridge is a Markdown reference to the same installed agent
instructions:

```md
Refer to [Pop Culture Agent](../pop-culture-agent/AGENTS.md) for agent progress-update style.
```

In global scope, the installer writes the shared agent files to
`~/.pop-culture-agent` by default and adds absolute bridge lines to:

- `~/.codex/AGENTS.md`
- `~/.claude/CLAUDE.md`
- `~/.gemini/GEMINI.md`

Global scope skips Copilot because Copilot instructions are repo-level
`.github/copilot-instructions.md` files.

The installer is idempotent and non-destructive: rerunning it creates any
missing bundled files and bridge lines, but preserves existing files and does
not duplicate bridge lines.

To refresh an existing install to the latest stock prompts and configs, use
update mode:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh -s -- --update
```

Update mode replaces the stock files in `pop-culture-agent/` and writes `.bak`
copies beside replaced files. It preserves an existing `quotes.json`; the latest
upstream quote bank is saved beside it as `quotes.json.latest` so custom quotes
can be merged deliberately.

The installer refuses to run from the Pop Culture Agent source repo by default,
so testing the installer here does not create local bridge files by accident.

## Choose A Mode

Improvise mode is the default. It prefers `quotes.json`, but lets the agent use
a short, contextually appropriate fallback line when the bank has no fresh fit.

To skip the prompt and install strict mode directly, run:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_MODE=strict sh
```

You can also pass the default mode explicitly; `open` and `improvise` are
equivalent:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_MODE=open sh
```

Under the hood, the generated `pop-culture-agent/AGENTS.md` includes exactly one
config file.

Improvisation mode uses:

```md
@./pop-culture-agent/config.open.md
```

This is the recommended default because it keeps the agent from going quiet
when the quote bank has no exact fit.

Strict mode uses:

```md
@./pop-culture-agent/config.strict.md
```

Strict mode uses only `quotes.json` and skips quotes when no bank quote fits.

To switch to strict mode later, edit `pop-culture-agent/AGENTS.md` and replace:

```md
@./pop-culture-agent/config.open.md
```

with:

```md
@./pop-culture-agent/config.strict.md
```

## Choose Agent Targets

By default, the installer targets `agents,claude,gemini,copilot`. To install
only specific bridge files without prompting, set `POP_CULTURE_AGENT_TARGETS`:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_TARGETS=agents,claude sh
```

For CI or other non-interactive installs, set the values explicitly:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_NONINTERACTIVE=1 POP_CULTURE_AGENT_SCOPE=repo POP_CULTURE_AGENT_MODE=strict POP_CULTURE_AGENT_TARGETS=agents,claude,gemini,copilot sh
```

To update non-interactively, set `POP_CULTURE_AGENT_UPDATE=1`:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_NONINTERACTIVE=1 POP_CULTURE_AGENT_UPDATE=1 sh
```

To run a non-interactive global install:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | POP_CULTURE_AGENT_NONINTERACTIVE=1 POP_CULTURE_AGENT_SCOPE=global POP_CULTURE_AGENT_MODE=strict POP_CULTURE_AGENT_TARGETS=agents,claude,gemini sh
```

## Example Output

```md
**The truth is out there.**

The issue is in `AuthReducer`: logout clears the token but leaves the refresh
task running.
```

## Customize

Edit `pop-culture-agent/quotes.json` to add or remove quotes. Edit
`pop-culture-agent/AGENTS.snippet.md` to change frequency, formatting, tone
modes, or selection rules. The installer preserves these files when rerun.

You can also ask your coding agent to expand the bank naturally:

```md
Add short quotes from Metal Gear Solid to Pop Culture Agent.
```

The installed instructions tell the agent to choose short, standalone lines,
categorize them by reasoning state, assign matching tones, and validate
`quotes.json`. Providing a few favorite exact lines works best.

## Uninstall

Remove the Pop Culture Agent bridge line from any generated instruction files,
then delete the `pop-culture-agent` directory.
