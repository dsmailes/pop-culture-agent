# Pop Culture Agent

Pop Culture Agent is a prompt-only add-on for making coding agent progress
updates a little more characterful. It installs the **Agent Quoteboard**
instructions into a target repository so compatible agents can replace bland
transition phrases with occasional short, bold pop-culture-style lines while
keeping technical updates clear.

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

- strict or improvise mode
- which agent bridge files to create

Press Enter for the recommended defaults: strict mode and all supported bridge
files.

If you do not want extra bridge files such as `CLAUDE.md`, `GEMINI.md`, or
`.github/copilot-instructions.md`, choose `AGENTS.md only` at the prompt.

The installer downloads `agent-quoteboard/`, writes the selected quote config,
and adds small bridge instructions for common coding agents:

- `AGENTS.md` for Codex-style and other `AGENTS.md` readers
- `CLAUDE.md` for Claude Code
- `GEMINI.md` for Gemini CLI
- `.github/copilot-instructions.md` for GitHub Copilot

For `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md`, the bridge line is:

```md
@./agent-quoteboard/AGENTS.md
```

For Copilot, the bridge is a Markdown reference to the same installed agent
instructions:

```md
Refer to [Agent Quoteboard](../agent-quoteboard/AGENTS.md) for agent progress-update style.
```

The installer is idempotent: rerunning it refreshes the bundled files without
duplicating bridge lines.

The installer refuses to run from the Pop Culture Agent source repo by default,
so testing the installer here does not create local bridge files by accident.

## Choose A Mode

Strict mode is the default. It uses only `quotes.json` and skips quotes when no
bank quote fits.

To skip the prompt and install improvise mode directly, run:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | AGENT_QUOTEBOARD_MODE=improvise sh
```

`open` is also accepted as an equivalent alias:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | AGENT_QUOTEBOARD_MODE=open sh
```

Under the hood, the generated `agent-quoteboard/AGENTS.md` includes exactly one
config file.

Strict mode uses:

```md
@./agent-quoteboard/config.strict.md
```

This is the recommended default because it keeps the behavior predictable.

Improvisation mode uses:

```md
@./agent-quoteboard/config.open.md
```

Improvisation mode prefers `quotes.json`, but lets the agent improvise a short
outside-bank line when the bank has no fresh fit.

To start improvising later, edit `agent-quoteboard/AGENTS.md` and replace:

```md
@./agent-quoteboard/config.strict.md
```

with:

```md
@./agent-quoteboard/config.open.md
```

## Choose Agent Targets

By default, the installer targets `agents,claude,gemini,copilot`. To install
only specific bridge files without prompting, set `AGENT_QUOTEBOARD_TARGETS`:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | AGENT_QUOTEBOARD_TARGETS=agents,claude sh
```

For CI or other non-interactive installs, set the values explicitly:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | AGENT_QUOTEBOARD_NONINTERACTIVE=1 AGENT_QUOTEBOARD_MODE=strict AGENT_QUOTEBOARD_TARGETS=agents,claude,gemini,copilot sh
```

## Example Output

```md
**The truth is out there.**

The issue is in `AuthReducer`: logout clears the token but leaves the refresh
task running.
```

## Customize

Edit `agent-quoteboard/quotes.json` to add or remove quotes. Edit
`agent-quoteboard/AGENTS.snippet.md` to change frequency, formatting, tone
modes, or selection rules.

You can also ask your coding agent to expand the bank naturally:

```md
Add short quotes from Metal Gear Solid to Agent Quoteboard.
```

The installed instructions tell the agent to choose short, standalone lines,
categorize them by reasoning state, assign matching tones, and validate
`quotes.json`. Providing a few favorite exact lines works best.

## Uninstall

Remove the Agent Quoteboard bridge line from any generated instruction files,
then delete the `agent-quoteboard` directory.
