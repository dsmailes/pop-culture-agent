# Agent Quoteboard

Agent Quoteboard is a small `AGENTS.md` behavior snippet that replaces bland
agent transition phrases with occasional short, bold pop-culture-style lines.

It is intentionally prompt-only. It does not install dependencies or change
runtime code. The optional quote bank is data-only JSON used to reduce
repetition.

## Install

Run this from the target repo:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | sh
```

When run in a terminal, the installer asks you to choose strict/improvise mode
and which agent bridge files to create. Press Enter for the recommended
defaults: strict mode and all supported bridge files.

If you do not want extra bridge files such as `CLAUDE.md`, `GEMINI.md`, or
`.github/copilot-instructions.md`, choose `AGENTS.md only` at the prompt.

The installer copies the `agent-quoteboard` directory into your repository, then
adds bridge instructions for common coding agents:

- `AGENTS.md` for Codex-style and other `AGENTS.md` readers
- `CLAUDE.md` for Claude Code
- `GEMINI.md` for Gemini CLI
- `.github/copilot-instructions.md` for GitHub Copilot

For `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md`, the bridge line is:

```md
@./agent-quoteboard/AGENTS.md
```

Keep your existing repo instructions in place. The snippet is additive and the
installer will not duplicate existing bridge lines.

## Install-Time Choice

Strict mode is the default. It uses only `quotes.json` and skips quotes when no
bank quote fits:

```md
@./agent-quoteboard/config.strict.md
```

This is the recommended default because it reduces repetition and keeps the
behavior predictable.

Skip the prompt and install improvisation mode with:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | AGENT_QUOTEBOARD_MODE=improvise sh
```

`open` is kept as an equivalent alias:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | AGENT_QUOTEBOARD_MODE=open sh
```

Improvisation mode uses:

```md
@./agent-quoteboard/config.open.md
```

It prefers `quotes.json`, but lets the agent improvise a short, contextually
appropriate line when the bank has no fresh fit.

To start improvising later, edit `agent-quoteboard/AGENTS.md` and replace the
strict config line with the open config line.

## Install-Time Agent Targets

By default, the installer targets `agents,claude,gemini,copilot`. To install
only specific bridge files without prompting, set `AGENT_QUOTEBOARD_TARGETS`:

```sh
curl -fsSL https://raw.githubusercontent.com/dsmailes/pop-culture-agent/main/install.sh | AGENT_QUOTEBOARD_TARGETS=agents,claude sh
```

## Uninstall

Remove the Agent Quoteboard bridge line from any generated instruction files,
then delete the `agent-quoteboard` directory.

## Tune

If the quotes feel too frequent, edit `AGENTS.snippet.md` and change the
frequency guidance from `3-5 agent updates` to a larger interval such as
`5-8 agent updates`.

## Quote Bank

`quotes.json` contains reusable quote entries tagged by reasoning state and
tone. Add new entries there when a phrase gets stale.

You can ask your coding agent to add quotes from a favorite source:

```md
Add short quotes from Metal Gear Solid to Agent Quoteboard.
```

The installed instructions tell the agent to choose short, standalone lines,
categorize them by reasoning state, assign matching tones, and validate the JSON.
Providing exact favorite lines gives the agent the cleanest input.

Each quote should stay short and use this shape:

```json
{
  "id": "bigger_boat",
  "quote": "We're gonna need a bigger boat.",
  "source": "Jaws",
  "source_type": "movie",
  "states": ["hidden_complexity"],
  "tones": ["default", "survival_horror"],
  "intensity": 0.7,
  "rarity": 0.2
}
```

Use `states` to decide when a quote applies, `tones` to match the requested
style, `intensity` to avoid over-dramatizing routine updates, and `rarity` to
keep distinctive quotes from showing up too often.

Agents should render selected quote text as bold Markdown without surrounding
inverted commas, for example:

```md
**We're gonna need a bigger boat.**
```
