# Agent Quoteboard

Agent Quoteboard is a prompt-only `AGENTS.md` add-on for making agent progress
updates a little more characterful. It replaces bland transition phrases with
occasional short, bold pop-culture-style lines while keeping technical updates
clear.

It is intentionally small:

- no package manager
- no runtime code
- no dependencies
- no build step

## Install

Run this from the root of the repo where you want Agent Quoteboard installed:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh
```

The installer downloads `agent-quoteboard/` and adds small bridge instructions
for common coding agents:

- `AGENTS.md` for Codex-style and other `AGENTS.md` readers
- `CLAUDE.md` for Claude Code
- `GEMINI.md` for Gemini CLI
- `.github/copilot-instructions.md` for GitHub Copilot

```md
@./agent-quoteboard/AGENTS.md
```

For Copilot, the bridge is a Markdown reference to the same installed agent
instructions because Copilot's repository instructions file does not use the
same import convention.

## Choose A Mode

Strict mode is the default. It uses only `quotes.json` and skips quotes when no
bank quote fits.

To let the agent improvise at install time:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | AGENT_QUOTEBOARD_MODE=improvise sh
```

`open` is kept as an equivalent alias:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | AGENT_QUOTEBOARD_MODE=open sh
```

Under the hood, use exactly one config file:

```md
@./agent-quoteboard/config.strict.md
```

This is the recommended default because it keeps the behavior predictable.

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
only specific bridge files, set `AGENT_QUOTEBOARD_TARGETS`:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | AGENT_QUOTEBOARD_TARGETS=agents,claude sh
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
